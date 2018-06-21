#!/usr/bin/python3

#
#      ______     ____    ______     ____    _____     ____     _____    __   __
#     | ___  \  / ___ \  | ___  \  / ___ \  | ___ \  / ___ \  / _____\  |  | / /
#    | |__| /  | |  | | | |__| /  | |  | | | |  | | | |  | | | |       |  |/ /
#   |      \  | |  | | |  ___ \  | |  | | | |  | | | |  | | | |       |    /
#  |  |\   \ | |__| | |  |__| | | |__| | | |__| | | |__| | | |_____  |  |\ \
# |__|  \__\ \_____/ |_______/  \_____/ |______/  \_____/  \______/ |__| \__\
#

# Written by Mutlu Polatcan
# 21.06.2018

import os


def save_gcloud_hosts():
    print("Saving hosts in Google Cloud Compute Engine...")

    os.system("sudo cat /etc/hosts.bak > hosts.tmp")

    gcloud_hosts = open(file="hosts.txt", mode="r")

    disable_header = True
    for line in gcloud_hosts.readlines():
        if not disable_header:
            tokens = line.split()

            # If server is running add to hosts file
            if tokens[tokens.__len__() - 1] == "RUNNING":
                print("Running instance " + tokens[0] + " with IP Address " + tokens[tokens.__len__() - 2] + " added to /etc/hosts file")
                os.system("sudo echo " + tokens[tokens.__len__() - 2] + " " + tokens[0] + " >> hosts.tmp")
        else:
            disable_header = False

    gcloud_hosts.close()

    os.system("sudo mv hosts.tmp /etc/hosts")


if __name__ == "__main__":
    os.system("gcloud compute instances list > hosts.txt")

    try:
        # Check backup hosts file if exist
        hosts = open(file="/etc/hosts.bak", mode="r")
        hosts.close()
    except IOError:
        # Save initial /etc/hosts file (backup)
        os.system("sudo cat /etc/hosts > /etc/hosts.bak")
    finally:
        save_gcloud_hosts()

    os.system("rm hosts.txt")

