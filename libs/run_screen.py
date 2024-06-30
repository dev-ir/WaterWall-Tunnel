import subprocess
import shlex

def check_and_install_screen():
  try:
    subprocess.run(['screen', '-v'], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
  except subprocess.CalledProcessError:
    print("screen not installed ....")
    subprocess.run(['sudo', 'apt', 'install', 'screen'], check=True)

def run_in_screen(command):
  check_and_install_screen()
  screen_command = shlex.split('screen -dmS waterwall {}'.format(command))
  subprocess.run(screen_command)

if __name__ == "__main__":
  run_in_screen('./Waterwall')
