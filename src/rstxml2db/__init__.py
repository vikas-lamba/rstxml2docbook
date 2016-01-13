#
# Copyright (c) 2015 SUSE Linux GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of version 3 of the GNU General Public License as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, contact SUSE LLC.
#
# To contact SUSE about this file by physical or electronic mail,
# you may find current contact information at www.suse.com

import argparse

__version__ = "0.0.1"


def main(cliargs=None):
   """Entry point for the application script

    :param list cliargs: Arguments to parse or None (=use sys.argv)
   """
   parser = argparse.ArgumentParser()

   parser.add_argument('-v', '--verbose', action='count',
                       help="Increase verbosity level")

   parser.add_argument('--version',
                       action='version',
                       version='%(prog)s ' + __version__
                       )

   parser.add_argument('indexfile',
                       help='index file (XML) which refer all other files')

   args = parser.parse_args(args=cliargs)

   print(args)