
from __future__ import print_function

import logging
import argparse
import platform
import tempfile
import os

from os import path
from shutil import rmtree
from subprocess import Popen, PIPE
from zipfile import ZipFile



logging.basicConfig()
logger = logging.getLogger(__name__)


PLATFORM = platform.system()
PLATFORM_ENV = {
    "Linux": {
        "sep": ':',
        "dir_temp": "/temp",
        "dir_bootstrap": "/bootstrap",
        "dir_puppettemp": "/tmp/puppet",
        "puppet_envpath": "/etc/puppetlabs/code/environments/production",
    },
    "Windows": {
        "sep": ';',
        "dir_temp": "c:\\windows\\temp",
        "dir_bootstrap": "c:\\bootstrap",
        "dir_puppettemp": "c:\\windows\\temp\\puppet",
        "puppet_envpath": "C:\\ProgramData\\PuppetLabs\\code\\environments\\production",
    }
}
ENV = PLATFORM_ENV[PLATFORM]
VERBOSE_LEVELS = (logging.WARNING, logging.INFO, logging.DEBUG)
PUPPET_VERBOSE = {
    logging.WARNING: "",
    logging.INFO: "--verbose",
    logging.DEBUG: "--debug",
}


def cli_exception(message, exitcode=255):
    print(message)
    exit(exitcode)

def run_command(command):

    cmd = command_wrapper(command)
    cmd_text = " ".join(cmd)

    logger.info('Running command %s', cmd_text)
    process = Popen(cmd)
    process.wait()
    return process

def command_wrapper(command):

    if platform.system() == "Windows":
        return ['c:\\windows\\system32\\cmd.exe', '/c'] + command
    elif platform.system() == "Linux":
        return command
    else:
        cli_exception("Unknown OS type")

def puppet_args_verbose():
    return PUPPET_VERBOSE[logger.getEffectiveLevel()]

def build_configure():

    os.chdir(ENV['dir_puppettemp'])

    manifest_file = path.join(ENV['dir_puppettemp'], "manifest.pp")
    args = ['--modulepath', 'modules' + ENV['sep'] + '$basemodulepath',
            '--detailed-exitcodes',
            '--hiera_config', 'hiera.yaml',
            puppet_args_verbose(),
            manifest_file]
    cmd = ["puppet", "apply"] + args

    process = run_command(cmd)
    if process.returncode != 2:
        cli_exception("Error: Puppet did not create any resources")


def runtime_configure():

    manifest_file = path.join(ENV['puppet_envpath'], "manifest.pp")
    args = ['--detailed-exitcodes',
            puppet_args_verbose(),
            manifest_file]
    cmd = ["puppet", "apply"] + args

    process = run_command(cmd)
    if process.returncode != 2:
        cli_exception("Error: Puppet did not create any resources")


def build_prep(zipfile):

    if not path.isfile(zipfile):
        cli_exception("Error: Can't find %s" % zipfile)

    puppet_dir = ENV['dir_puppettemp']

    if path.isfile(puppet_dir):
        logger.warning('Removing file %s', puppet_dir)
        os.remove(puppet_dir)

    if path.isdir(puppet_dir):
        logger.warning('Removing Directory Contents %s', puppet_dir)
        rmtree(puppet_dir)

    with ZipFile(zipfile, 'r') as zip_ref:
        zip_ref.extractall(puppet_dir)



def build_install():
    """
    Install puppet modules from build dir to $basemodulepath:
        puppet apply -e "include clgxutil::local_module_copy"

    """
    os.chdir(ENV['dir_puppettemp'])
    cmd = ['puppet', 'apply',
           '--modulepath', 'modules' + ENV['sep'] + '$basemodulepath',
           '--detailed-exitcodes',
           '--hiera_config', 'hiera.yaml',
           puppet_args_verbose()]


    module_copy = cmd + ['-e', 'include clgxutil::imageprep']
    process = run_command(module_copy)


def set_facts():

    manifest_file = path.join(ENV['dir_puppettemp'], "manifest.pp")
    cmd = ['puppet', 'apply',
           '--modulepath', 'modules' + ENV['sep'] + '$basemodulepath',
           puppet_args_verbose()]
    cmd += ['-e', 'include clgxutil::bootstrap::userdata_customfacts']

    process = run_command(cmd)


def define_menu():

    parser = argparse.ArgumentParser()
    parser.add_argument('--verbose', '-v', default=0, help="Verbosity (additional for more)", action='count')
    subparsers = parser.add_subparsers()

    p_build_configure = subparsers.add_parser(
        'build-configure',
        help="Run Puppet apply for image builds")
    p_build_prep = subparsers.add_parser(
        'build-prep',
        help="Prep the build package for build-configure")
    p_build_install = subparsers.add_parser(
        'build-install',
        help="Install puppet modules & code for runtime use")
    p_runtime_configure = subparsers.add_parser(
        'runtime-configure',
        help="Run Puppet apply for system runtime")
    p_set_facts = subparsers.add_parser(
        'set-facts',
        help="Set custom facts from environment (user-data)")

    p_build_configure.set_defaults(action='build-configure')
    p_build_prep.set_defaults(action='build-prep')
    p_build_install.set_defaults(action='build-install')
    p_runtime_configure.set_defaults(action='runtime-configure')
    p_set_facts.set_defaults(action='set-facts')

    p_build_prep.add_argument("zipfile", help="Path to Puppet zip file")
    return parser

def main():
    parser = define_menu()
    args = parser.parse_args()


    verbosity = VERBOSE_LEVELS[args.verbose] \
        if args.verbose < len(VERBOSE_LEVELS) else VERBOSE_LEVELS[-1]
    logger.setLevel(verbosity)

    if args.action == 'build-configure':
        build_configure()
    elif args.action == 'build-prep':
        build_prep(args.zipfile)
    elif args.action == 'build-install':
        build_install()
    elif args.action == 'runtime-configure':
        runtime_configure()
    elif args.action == 'set-facts':
        set_facts()

if __name__ == "__main__":
    main()
