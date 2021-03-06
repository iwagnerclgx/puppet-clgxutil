
from __future__ import print_function

import logging
import argparse
import tempfile
import platform
import os
import re

from os import path
from shutil import rmtree
from subprocess import Popen, PIPE, list2cmdline
from zipfile import ZipFile
from base64 import b64encode


logging.basicConfig()
logger = logging.getLogger(path.basename(__file__))


PLATFORM = platform.system()
PLATFORM_ENV = {
    "Linux": {
        "sep": ':',
        "dir_temp": "/tmp",
        "dir_bootstrap": "/bootstrap",
        "dir_puppettemp": "/tmp/puppet",
        "puppet_envpath": "/etc/puppetlabs/code/environments/production",
        "cleanup_exclusion_file": "/tmp/.imageprep_tmpfilelist.txt"
    },
    "Windows": {
        "sep": ';',
        "dir_temp": 'c:/windows/temp',
        "dir_bootstrap": "c:/bootstrap",
        "dir_puppettemp": "c:/windows/temp/puppet",
        "puppet_envpath": "C:/ProgramData/PuppetLabs/code/environments/production",
        "cleanup_exclusion_file": "c:/windows/temp/imageprep_tmpfilelist.txt"
    }
}
ENV = PLATFORM_ENV[PLATFORM]
VERBOSE_LEVELS = (logging.INFO, logging.DEBUG)
PUPPET_VERBOSE = {
    logging.INFO: "--verbose",
    logging.DEBUG: "--debug",
}


def cli_exception(message, exitcode=255):
    print(message)
    exit(exitcode)

def run_command(command, valid_exit=[0]):

    cmd = command_wrapper(command)
    cmd_text = " ".join(cmd)

    logger.debug('Running command %s', cmd_text)
    process = Popen(cmd)
    process.wait()
    logger.info('Return code: %s', process.returncode)

    if process.returncode not in valid_exit:
        cli_exception("Command unsuccessful. Returned: %s" % process.returncode)


def powershell_escape(commandlist):
    """
    Here we are escaping the sequence into a string so that we can pass the
    whole encoded string to powershell. I.e. a command inside a command.

    First, loop through the sequence, and backtick escape ; and $
    Second, pass sequence to subprocess.list2cmdline to generate a command string
    as it would be by a regular Popen.
    """
    reg_escape = re.compile("([$;])")
    new_commands = []
    for item in commandlist:
        item = reg_escape.sub(r"`\1", item)
        new_commands.append(item)

    # Convert list to string
    cmdstring = '& ' + list2cmdline(new_commands)
    # Change \ to ` -- Powershell encoded commands use different escape
    cmdstring = cmdstring.replace(chr(92), '`')
    cmdstring += '; exit $LASTEXITCODE'
    logger.debug('Windows Pre-encoded command: %s', cmdstring)
    return cmdstring


def powershell_encoded_command(cmdstring):
    """
    Here we are manually manipulating the UTF encoding to be able to properly
    base64encode the command
    """
    # base64encode the string
    encoded = "".join([x + '\x00' for x in unicode(cmdstring)])
    logger.debug('Windows encoded command: %s', encoded)

    return b64encode(encoded)

def command_wrapper(command, os_platform=None):

    logger.info('New command: %s', command)

    if not os_platform:
        os_platform = platform.system()

    if os_platform == "Windows":
        escaped_command = powershell_escape(command)
        encoded_command = powershell_encoded_command(escaped_command)

        popen_command = [
            'powershell' ,'-executionpolicy' ,'bypass',
            '-encodedCommand', encoded_command]
        return popen_command
    elif os_platform == "Linux":
        return command
    else:
        cli_exception("Unknown OS type")

def puppet_args_verbose():
    return PUPPET_VERBOSE[logger.getEffectiveLevel()]

def puppet_apply(ignore_apply_error=False):

    # Allow all detailed-exitcodes if ignore, else 2
    acceptable_return = range(0,7) if ignore_apply_error else [2]
    logging.info("Running Puppet apply for image (puppet-apply)")
    os.chdir(ENV['dir_puppettemp'])

    manifest_file = "/".join([ENV['dir_puppettemp'], "manifest.pp"])
    args = ['--modulepath', 'site' + ENV['sep'] + 'modules' + ENV['sep'] + '$basemodulepath',
            '--detailed-exitcodes',
            '--hiera_config', 'hiera.yaml',
            puppet_args_verbose(),
            manifest_file]
    cmd = ["puppet", "apply"] + args

    run_command(cmd, valid_exit=acceptable_return)


def build_prep(zipfile):
    logger.info("Unzipping Puppet Masterless archive (build-prep)")

    if not path.isfile(zipfile):
        cli_exception("Error: Can't find %s" % zipfile)

    puppet_dir = ENV['dir_puppettemp']

    if path.isfile(puppet_dir):
        logger.warning('Removing file %s', puppet_dir)
        os.remove(puppet_dir)

    if path.isdir(puppet_dir):
        logger.warning('Removing Directory Contents %s', puppet_dir)
        rmtree(puppet_dir)


    existing_files = os.listdir(ENV['dir_temp'])
    logger.debug('Pre-existing files: %s', existing_files)
    # Write a list of files in tmp for cleanup exclusion later
    with open(ENV['cleanup_exclusion_file'], 'w') as fd:
        fd.write("\n".join(existing_files))

    os.mkdir(puppet_dir)
    os.chdir(puppet_dir)

    with ZipFile(zipfile, 'r') as zip_ref:
        zip_ref.extractall(puppet_dir)



def imageprep():
    logger.info("Prepping image for Baking (imageprep)")

    cmd = ['puppet', 'apply',
           '--modulepath', 'site' + ENV['sep'] + 'modules' + ENV['sep'] + '$basemodulepath',
           '--detailed-exitcodes',
           '--hiera_config', 'hiera.yaml',
           puppet_args_verbose()]


    module_copy = 'include clgxutil::imageprep'

    os.chdir(ENV['dir_puppettemp'])
    run_command(cmd + ['-e', module_copy], valid_exit=[0,2])

    with open(ENV['cleanup_exclusion_file'], 'r') as fd:
        exclude_list = fd.read().split("\n")

    os.chdir(ENV['dir_temp'])
    temp_files = os.listdir(ENV['dir_temp'])
    for temp_file in temp_files:
        if temp_file in exclude_list:
            logger.info("Skipping Pre Exising temp file: %s" % temp_file)
        else:
            logger.info("Deleting temp file/dir: %s" % temp_file)

            try:
                if path.isfile(temp_file):
                    os.remove(temp_file)
                else:
                    rmtree(temp_file)
            except Exception as e:
                logger.warning(e)

def set_runtime_facts():
    logger.info("Setting instance facts")

    cmd = ['puppet', 'apply',
           '--modulepath', 'site' + ENV['sep'] + 'modules' + ENV['sep'] + '$basemodulepath',
           '--hiera_config', 'hiera.yaml',
           puppet_args_verbose()]
    cmd += ['-e', 'class {"clgxutil::bootstrap::userdata_customfacts": static_facts => {"image_lifecycle" =>{"name" => "image_lifecycle", "value" => "runtime"}} }']

    run_command(cmd, valid_exit=[0])

def set_build_facts():
    logger.info("Setting instance build facts")
    cmd = ['puppet', 'apply',
           '--modulepath', 'site' + ENV['sep'] + 'modules' + ENV['sep'] + '$basemodulepath',
           '--hiera_config', 'hiera.yaml',
           puppet_args_verbose()]

    os.chdir(ENV['dir_puppettemp'])
    cmd += ['-e', 'class {"clgxutil::bootstrap::userdata_customfacts": static_facts => {"image_lifecycle" =>{"name" => "image_lifecycle", "value" => "build"}} }']
    run_command(cmd, valid_exit=[0])

def define_menu():

    parser = argparse.ArgumentParser()
    parser.add_argument('--verbose', '-v', default=0, help="Verbosity (additional for more)", action='count')
    parser.add_argument('--ignore-apply-error', default=False, action='store_true',
                        help="Don't error on puppet apply")
    subparsers = parser.add_subparsers()

    p_puppet_apply = subparsers.add_parser(
        'puppet-apply',
        help="Run Puppet apply for image builds")
    p_build_prep = subparsers.add_parser(
        'build-prep',
        help="Prep the build package for puppet-apply")
    p_imageprep = subparsers.add_parser(
        'imageprep',
        help="Install puppet modules & code for runtime use")
    p_set_runtime_facts = subparsers.add_parser(
        'set-runtime-facts',
        help="Set custom facts from environment (user-data)")
    p_set_build_facts = subparsers.add_parser(
        'set-build-facts',
        help="Set Facts to apply image build classes only")

    p_puppet_apply.set_defaults(action='puppet-apply')
    p_build_prep.set_defaults(action='build-prep')
    p_imageprep.set_defaults(action='imageprep')
    p_set_runtime_facts.set_defaults(action='set-runtime-facts')
    p_set_build_facts.set_defaults(action='set-build-facts')

    p_build_prep.add_argument("zipfile", help="Path to Puppet zip file")
    return parser

def main():
    parser = define_menu()
    args = parser.parse_args()

    verbosity = VERBOSE_LEVELS[args.verbose] \
        if args.verbose < len(VERBOSE_LEVELS) else VERBOSE_LEVELS[-1]
    logger.setLevel(verbosity)

    if args.action == 'puppet-apply':
        puppet_apply(ignore_apply_error=args.ignore_apply_error)
    elif args.action == 'build-prep':
        build_prep(args.zipfile)
    elif args.action == 'imageprep':
        imageprep()
    elif args.action == 'set-runtime-facts':
        set_runtime_facts()
    elif args.action == 'set-build-facts':
        set_build_facts()

    exit(0)

if __name__ == "__main__":
    main()

    exit(0)
