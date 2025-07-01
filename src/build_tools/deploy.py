import os
import sys
import shutil
import subprocess
import argparse

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '../..'))

RELEASE_BRANCHES = {
    'assignment':   'release/assignment',
    'report':       'release/report'
}

def run_command(command, working_dir) -> str:
    """
    Executes a shell command and returns stdout.
    """
    print(f"Running command: '{' '.join(command)}' in '{working_dir}'")
    try:
        result = subprocess.run(
            command,
            cwd=working_dir,
            check=True,
            capture_output=True,
            text=True,
        )
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {' '.join(command)}")
        print(e.stderr)
        raise
    return result.stdout

def get_head_commit_version(path: str) -> str:
    commit_msg = run_command(['git', 'show', '--pretty=format:%s', '-s', 'HEAD'], path)
    version = commit_msg.split(' ')[-1]
    return version

def get_base_tag() -> str:
    run_command(['git', 'fetch', '--tags'], PROJECT_ROOT)
    tag = run_command(['git', 'describe', '--tags'], PROJECT_ROOT)
    tag = tag.split('-')[0]
    return tag

def main() -> None:
    """
    Main entry point.
    """
    parser = argparse.ArgumentParser(
        prog='Test',
        description='Test Description',
    )
    parser.add_argument(
        'TEMPLATE_TYPE',
        choices=RELEASE_BRANCHES.keys()
    )
    args = parser.parse_args()

    TEMPLATE_TYPE   = args.TEMPLATE_TYPE
    DEPLOY_BRANCH   = RELEASE_BRANCHES[TEMPLATE_TYPE]
    BASE_TAG        = get_base_tag()
    TEMP_DIR        = f'tmp_deploy_{TEMPLATE_TYPE}'
    TEMP_DIR_FULL   = os.path.join(PROJECT_ROOT, TEMP_DIR)

    ## Clone repo to prepare release branch
    run_command(['git',
                 'clone',
                 f'https://x-access-token:{GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git',
                 TEMP_DIR], PROJECT_ROOT)

    ## Checkout release branch
    run_command(['git', 'checkout', '-B', f'{DEPLOY_BRANCH}'], TEMP_DIR_FULL)

    ## Get latest release version
    branch_version = get_head_commit_version(TEMP_DIR_FULL)


    ## Clear release branch
    run_command(['rm', '-rf', './*'], TEMP_DIR_FULL)

    tag = get_base_tag()
    print(tag)

    return


if __name__ == "__main__":
    main()
    exit()