##
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##

from libcpp.memory cimport shared_ptr
from libcpp.memory cimport unique_ptr
from libcpp.utility cimport move
from libcpp.vector cimport vector
from libcpp.string cimport string
from libcpp cimport bool
from cython.operator cimport dereference as deref
from pygcylon.ctx.context cimport CCylonContext
from pygcylon.ctx.context cimport CylonContext
from pygcylon.api.lib cimport pycylon_unwrap_context

from pygcylon.data.table cimport Shuffle

from cudf._lib.cpp.table.table_view cimport table_view
from cudf._lib.cpp.table.table cimport table
from cudf._lib.cpp.column.column cimport column
from cudf._lib.table cimport Table
from cudf._lib.column cimport Column

def shuffle(object tbl, hash_columns, context):
    cdef CStatus status
    cdef Table inputTable = tbl
    cdef table_view inputTview = inputTable.view()
    cdef unique_ptr[table] output
    cdef vector[int] c_hash_columns
    cdef Table outputTable
    cdef shared_ptr[CCylonContext] c_ctx_ptr = pycylon_unwrap_context(context)

    if hash_columns:
        c_hash_columns = hash_columns

        status = Shuffle(inputTview, c_hash_columns, c_ctx_ptr, output)
        if status.is_ok():
            outputTable = Table.from_unique_ptr(move(output), inputTable._column_names, index_names=inputTable._index_names)
            return outputTable
        else:
            raise ValueError(f"Shuffle operation failed : {status.get_msg().decode()}")
    else:
        raise ValueError('Hash columns are not provided')


