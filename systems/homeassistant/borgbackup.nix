{ ... }:
{
  /*
    https://christine.website/blog/borg-backup-2021-01-09

    mkdir mount
    borg-job-borgbase mount kuji7rr6@kuji7rr6.repo.borgbase.com:repo ./mount

    borg-job-borgbase umount ./mount
  */
  services.borgbackup.jobs."borgbase" = {
    compression = "auto,lzma";
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat /root/borgbackup_passphrase";
    };
    environment.BORG_RSH = "ssh -i /root/borgbackup_ssh";
    exclude =
      [
      ];
    paths = [
      "/srv"
    ];
    prune.keep = {
      within = "1d";
      daily = 3;
      weekly = 2;
      monthly = 1;
    };
    repo = "kuji7rr6@kuji7rr6.repo.borgbase.com:repo";
    startAt = "daily";
  };
}
