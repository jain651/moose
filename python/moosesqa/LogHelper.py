#* This file is part of the MOOSE framework
#* https://www.mooseframework.org
#*
#* All rights reserved, see COPYRIGHT for full restrictions
#* https://github.com/idaholab/moose/blob/master/COPYRIGHT
#*
#* Licensed under LGPL 2.1, please see LICENSE for details
#* https://www.gnu.org/licenses/lgpl-2.1.html
import collections
import logging

class LogHelper(object):
    """Tool for allowing log level for individual log messages"""
    def __init__(self, logger_name, *keys, default=logging.ERROR, **kwargs):
        self.__logger = logging.getLogger(logger_name)
        self.__modes = {k:default for k in keys}
        self.__counts = collections.defaultdict(int)
        for key, value in kwargs.items():
            self.setLevel(key, value)

    @property
    def modes(self):
        """Return the counts for each key"""
        return self.__modes

    @property
    def counts(self):
        """Return the counts for each key"""
        return self.__counts

    def setLevel(self, key, level):
        """Add/set the desired log level for a given key"""
        self.__modes[key] = level

    def log(self, key, msg, *args, **kwargs):
        """Wrapper for logging log that uses the key to determine the message level"""
        mode = self.__modes[key]
        self.__counts[key] += 1
        if mode is not None:
            text = msg.format(*args, **kwargs)
            self.__logger.log(mode, text)
