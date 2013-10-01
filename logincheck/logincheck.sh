#!/bin/bash

# login check #
###############

# Ich möchte benachrichtigt werden, wenn sich jemand am 14x3 anmeldet.
# Hierfür wird in kurzen Abständen ein Cronjob gestartet, der dieses Script ausführt.
# Um den User zu erkennen, der sich angemeldet hat, wird "lastlog"
# Der Befehl "lastlog" wird hierbei gefiltert und mit einem älterem
# Ergebnis verglichen. Das gleiche gilt auch für den sftp-check,
# jedoch wird hierbei das "auth.log" nach sftp gefiltet. Nach root wird
# hier nicht gesucht, hierfür liegt ein entsprechender Befehl in seiner .bashrc

# [START]

# for debugging output remove the hash

# echo ""
# echo "THE LOGIN CHECK"
# echo "created to detect userlogin over bash and sftp"
# echo ""
# echo "Date: `date` Host: `hostname`"
# echo "be shure you always know where your towel is"
# echo ""
# echo ""

## Variablen

# echo "setting up variables"
  bashlog="/root/scripts/tmp/bashlog.txt"
  authlog="/var/log/auth.log"
  sftplog="/root/scripts/tmp/sftplog.txt"
# echo "done..."

## user bash check #
 ###################

# echo ""
# echo "starting process..........."
# echo ""
# echo "start user login check"
# echo "search for DIFF file"

## Falls die Vergleichsdatei nicht existiert, erstelle sie und beende das Script

  if [ ! -f $bashlog ]; then
      lastlog > $bashlog
#     echo "no files found to diff. EXIT!"
      echo "no files found to diff. EXIT!" | mail -s "`hostname`: USER LOGIN-DETECTION FAILED" tom
      exit 1
  fi
# echo "found DIFF file, start diffing lastlog..."

## aktueller Loginstatus wird mit der Vergleichsdatei abgeglichen und nur Zeilen angezeitgt,
## die weder "**Never logged in** noch root beinhalten und mit einen '>' beginnen

  output=$(diff -B <(cat $bashlog) <(lastlog | grep -v "**Never logged in**" | grep -v ^root) | grep "^>")

## Der abweichende Output wird gespeichert und per Mail zugestellt.
## Danach wird die Vergleichsdateiatei für den nächsten Durchlauf neu geschrieben.

  if [ $? = 0 ]; then
      i=$(echo $output | awk '{ print $2 }')
#     echo "USER LOGIN DETECTED BY '$i' - $output"
      echo $output | mail -s "`hostname`: USER LOGIN BY: '$i' DETECTED" tom
      lastlog > $bashlog
# else
#     echo "NO USER LOGIN FOUND on `hostname`"
  fi
# echo "finish user login check"
# echo ""

## sftp login check #
 ####################

# echo "start sftp login check"
# echo "search for DIFF file"

  if [ ! -f $sftplog ]; then
      cp $authlog $sftplog
#     echo "no files found to diff. EXIT!"
      echo "no files found to diff. EXIT!" | mail -s "`hostname`: SFTP LOGIN-DETECTION FAILED" tom
      exit 1
  fi

# echo "found DIFF file, start diffing auth.log..."
  soutput=$(diff -B <(cat $sftplog | grep sftp) <(cat $authlog | grep sftp) | grep "^>")
  if [ $? = 0 ]; then
      ii=$(echo $soutput | awk '{ print $13 }')
#     echo "SFTP LOGIN BY: '$ii' - $soutput"
      echo $soutput | mail -s "`hostname`: SFTP LOGIN BY: '$ii' DETECTED" tom
      cp $authlog $sftplog
# else
#     echo "NO SFTP LOGIN DETECTED on `hostname`"
  fi
# echo "finish sftp login check"

# echo ""
# echo "EXIT"
# echo ""
# echo ""
