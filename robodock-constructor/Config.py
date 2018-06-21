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

import yaml

class Config:
    def __init__(self, config_filename):
        try:
            self.config = yaml.load(open(config_filename, "r"))
        except yaml.YAMLError as err:
            print(err)

    def __check_attr_defined(self, attr_name):
        return self.config.keys().__contains__(attr_name)

    def get_int(self, attr_name):
        if self.__check_attr_defined(attr_name=attr_name):
            return int(self.config[attr_name])
        else:
            return None

    def get_str(self, attr_name):
        if self.__check_attr_defined(attr_name=attr_name):
            return str(self.config[attr_name])
        else:
            return None

    def get(self, attr_name):
        if self.__check_attr_defined(attr_name=attr_name):
            return self.config[attr_name]
        else:
            return None

    def len(self, attr_name):
        if self.__check_attr_defined(attr_name=attr_name):
            self.config[attr_name].__len__()
        else:
            return 0

    # Returns count of service which is defined by attr_name
    def count(self, attr_name):
        if self.__check_attr_defined(attr_name=attr_name):
            return self.nodes(attr_name).__len__()
        else:
            return 0

    # Returns configs for current service which is defined by attr_name
    def configs(self, attr_name):
        if self.__check_attr_defined(attr_name=attr_name) and \
           self.get(attr_name=attr_name) is not None and \
           self.get(attr_name=attr_name).keys().__contains__("configs") and \
           self.get(attr_name=attr_name)["configs"] is not None:
                return self.config[attr_name]["configs"]
        else:
            return []

    def nodes(self, attr_name):
        if self.__check_attr_defined(attr_name=attr_name) and \
           self.get(attr_name=attr_name) is not None and \
           self.get(attr_name=attr_name).keys().__contains__("nodes") and \
           self.get(attr_name=attr_name)["nodes"] is not None:
                return self.get(attr_name=attr_name)["nodes"].split(',')
        else:
            return []
