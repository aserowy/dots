{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    pkgs.python3Minimal
  ];

  environment.etc."fan-control.py" = {
    text = ''
      import RPi.GPIO as IO

      import signal
      import subprocess
      import time

      IO.setwarnings(False)
      IO.setmode (IO.BCM)
      IO.setup(14,IO.OUT)

      # Set GPIO14 as a PWM output, with 100Hz frequency (this should match your fans specified PWM frequency)
      fan = IO.PWM(14,100)
      fan.start(0)

      minTemp = 25
      maxTemp = 80
      minSpeed = 0
      maxSpeed = 100

      class SignalHandler:
        shutdown_requested = False

        def __init__(self):
            signal.signal(signal.SIGINT, self.request_shutdown)
            signal.signal(signal.SIGTERM, self.request_shutdown)

        def request_shutdown(self, *args):
            print('Request to shutdown received, stopping')
            self.shutdown_requested = True

        def can_run(self):
            return not self.shutdown_requested

      def get_temp():
          output = subprocess.run(['vcgencmd', 'measure_temp'], capture_output=True)
          temp_str = output.stdout.decode()
          try:
              return float(temp_str.split('=')[1].split("\'")[0])
          except (IndexError, ValueError):
              raise RuntimeError('Could not get temperature')
            
      def renormalize(n, range1, range2):
          delta1 = range1[1] - range1[0]
          delta2 = range2[1] - range2[0]
          return (delta2 * (n - range1[0]) / delta1) + range2[0]

      signal_handler = SignalHandler()
      while signal_handler.can_run():
          temp = get_temp()

          if temp < minTemp:
              temp = minTemp
          elif temp > maxTemp:
              temp = maxTemp

          temp = int(renormalize(temp, [minTemp, maxTemp], [minSpeed, maxSpeed]))

          fan.ChangeDutyCycle(temp)

          time.sleep(5)
    '';
  };

  systemd.services.fan-control = {
    description = "fan pwm control";
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.bash ];
    serviceConfig = {
      ExecStart = "python3 /etc/fan-control.py";
    };
  };
}
