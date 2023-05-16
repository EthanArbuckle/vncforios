# This is invoked by an xcode run script
import subprocess
import os

ROOTLESS_TARGET = True

DEVICE_SSH_PORT = "2223"
DEVICE_SSH_IP = "localhost"
TARGET_EXECUTABLE_NAME = "vncforios"

TARGET_INSTALL_PATH = "/usr/bin/"
if ROOTLESS_TARGET:
    TARGET_INSTALL_PATH = "/fs/jb/usr/bin/"


def run_command_on_device(command: str) -> bytes:
    return subprocess.check_output(
        f'ssh -oStricthostkeychecking=no -oUserknownhostsfile=/dev/null -p {DEVICE_SSH_PORT} root@{DEVICE_SSH_IP} "{command}"',
        shell=True,
    )


def copy_file_to_device(local: str, remote: str) -> None:
    subprocess.check_output(
        f'scp -oStricthostkeychecking=no -oUserknownhostsfile=/dev/null -P {DEVICE_SSH_PORT} "{local}" root@{DEVICE_SSH_IP}:"{remote}"',
        shell=True,
    )


def delete_file_from_device(remote: str) -> None:
    run_command_on_device(f"rm -f {remote}")


def kill_running_processes() -> None:
    try:
        run_command_on_device(f"killall -9 {TARGET_EXECUTABLE_NAME}")
    except:
        pass


def does_file_exist_on_device(remote: str) -> bool:
    try:
        run_command_on_device(f"ls -l {remote}")
        return True
    except:
        pass
    return False


def codesign_remote_executable(remote_executable: str, remote_entitlements: str) -> None:
    # Use ldid or jtool depending on what is available
    if does_file_exist_on_device("/usr/bin/ldid"):
        subprocess.check_output(
            f'ssh -oStricthostkeychecking=no -oUserknownhostsfile=/dev/null -p {DEVICE_SSH_PORT} root@{DEVICE_SSH_IP} "/usr/bin/ldid -S{remote_entitlements} {remote_executable}"',
            shell=True,
        )
    elif does_file_exist_on_device("/usr/local/bin/jtool"):
        subprocess.check_output(
            f'ssh -oStricthostkeychecking=no -oUserknownhostsfile=/dev/null -p {DEVICE_SSH_PORT} root@{DEVICE_SSH_IP} "/usr/local/bin/jtool --sign --inplace --ent {remote_entitlements} {remote_executable}"',
            shell=True,
        )
    else:
        raise Exception("Failed to find jtool or ldid on the device")


if __name__ == "__main__":

    device_connected = does_file_exist_on_device("/fs/jb/bin/ls")
    if not device_connected:
        raise Exception("not deploying to device because no jailbroken device is found")

    device_name = run_command_on_device("uname -a")
    print(f"deploying {TARGET_EXECUTABLE_NAME} to {device_name}")

    # Xcode provides the compiled executable and entitlement plist
    xcode_fresh_executable = os.getenv("BUILD_OUTPUT")
    entitlement_file = os.getenv("ENTITLEMENT_FILE")

    if not xcode_fresh_executable or not entitlement_file:
        raise Exception("Did not get entitlements or build executable from Xcode")

    # Kill old instances of the process that may be running on the device
    kill_running_processes()

    # Locally sign the build
    subprocess.check_output(
        f"/opt/homebrew/bin/ldid2 -S{entitlement_file} {xcode_fresh_executable}",
        shell=True,
    )

    # Delete old versions of the executable from the device (to delete cached cs blobs)
    remote_path = os.path.join(TARGET_INSTALL_PATH, TARGET_EXECUTABLE_NAME)
    delete_file_from_device(remote_path)

    # Copy new executable
    copy_file_to_device(xcode_fresh_executable, remote_path)
