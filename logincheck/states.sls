/root/scripts:
  file.directory:
    - user: root
    - group: root
    - mode: 750

/root/scripts/logincheck.sh:
  file.managed:
    - mode: 750
    - source: salt://scripts/logincheck.sh
    - require:
      - file.directory: /root/scripts

/root/scripts/logincheck.sh > /dev/null:
  cron:
  - present
  - user: root
  - minute: '*/1'
  - require:
    - file: /root/scripts/logincheck.sh


