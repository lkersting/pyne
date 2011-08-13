"""Python wrapper for isoname library."""
# Cython imports
from libcpp.map cimport map as cpp_map
from libcpp.set cimport set as cpp_set
from cython cimport pointer
from cython.operator cimport dereference as deref
from cython.operator cimport preincrement as inc
from libc.stdlib cimport free

# local imports 
cimport std
cimport cpp_pyne

import os

import pyne.__init__

_local_dir = os.path.split(pyne.__init__.__file__)[0]

lib = os.path.join(_local_dir, 'lib')
includes = os.path.join(_local_dir, 'includes')
nuc_data = os.path.join(_local_dir, 'nuc_data.h5')


####################################
### pyne configuration namespace ###
####################################

# Expose the C-code start up routine
def pyne_start():
    # Specifiy the BRIGHT_DATA directory
    if "PYNE_DATA" not in os.environ:
        os.environ['PYNE_DATA'] = _local_dir

    # Specifiy the NUC_DATA_PATH 
    if "NUC_DATA_PATH" not in os.environ:
        os.environ['NUC_DATA_PATH'] = nuc_data

    # Call the C-version of pyne_start
    cpp_pyne.pyne_start()


# Run the appropriate start-up routines
pyne_start()


################################
### PyNE Configuration Class ###
################################
cdef class PyneConfig:
    """A PyNE configuration helper class."""

    property PYNE_DATA:
        def __get__(self):
            cdef std.string value = cpp_pyne.PYNE_DATA
            return value.c_str()

        def __set__(self, char * value):
            cpp_pyne.PYNE_DATA = std.string(value)


    property NUC_DATA_PATH:
        def __get__(self):
            cdef std.string value = cpp_pyne.NUC_DATA_PATH
            return value.c_str()

        def __set__(self, char * value):
            cpp_pyne.NUC_DATA_PATH = std.string(value)


        
# Make a singleton of the pyne config object
pyne_config = PyneConfig()


