#!/bin/bash

service_loc="service"
DIR="./out/0"

THIS_DIR=`dirname $0`
source $THIS_DIR/set-of-vars.sh

echo "$THIS_DIR THIS_DIR"
echo "$dgraphVersion dgraphVersion"

# modified schema where default type is switched to string
# after this change, predicate_with_default_type will appear
SCHEMA="./${service_loc}/export/dgraph-1-2018-09-27-19-54.schema"

# unmodified schema from export; none of my predicates appear in dgraph schema
#SCHEMA="./${service_loc}/export/dgraph-1-2018-09-27-19-54.schema.gz"

RDFFILE="./${service_loc}/export/dgraph-1-2018-09-27-19-54.rdf.gz"

# The original dgraph movie dataset
#SCHEMA="./${service_loc}/1million.schema"
#RDFFILE="./${service_loc}/1million.rdf.gz"


my_server=${addrHost}:7080
my_zero=${addrHost}:${zeroPort}


my_server_p_0=${DIR}/p


echo "========================================="
echo "Log of Vars"
echo "========================================="

ls -la .

echo "Current ==> Location $(pwd)"

echo "DIR DIR"
echo "SCHEMA ${SCHEMA}"
echo "RDFFILE ${RDFFILE}"
echo "my_server ${my_server}"
echo "my_zero ${my_zero}"
echo "my_server_memory ${my_server_memory}"
echo "my_server_p_0 ${my_server_p_0}"
echo "========================================="

 check_existing_dir () {
      if [ ! -d "${DIR}" ]; then
          echo "directory OUT/ from Bulk - not found!"
          return 1
      else
          echo "$DIR WOOOOHOOOOO we have a directory!"
          echo "================= DIR ==================="
          ls -la $DIR
          echo "========================================="
          return 0
      fi
}


 check_existing_Schema () {
      if [ ! -f "${SCHEMA}" ]; then
          echo "Schema not found!"
          return 1
      else
          # echo "$FILE WOOOOHOOOOO"
          echo "=================Schema=================="
          cat $SCHEMA
          echo "========================================="
          return 0
      fi
}

 check_existing_RDF () {
      if [ ! -f "${RDFFILE}" ]; then
          echo "RDF not found!"
          return 1
      else
          # echo "$FILE WOOOOHOOOOO"
          echo "=================We have a RDF file =================="
          return 0
      fi
}

   tell_him () {
      echo "No need for a Bulk today!"
  }

   RUN_server () {
      echo "Dgraph server Starting ..."
      dgraph server --bindall=true --my=${my_server} --lru_mb=${my_server_memory} --zero=${my_zero} -p ${my_server_p_0}
  }

   RUN_BulkLoader () {
    if check_existing_RDF; then
      echo "Dgraph BulkLoader Starting..."
      dgraph bulk -r ${RDFFILE} -s ${SCHEMA} --reduce_shards=1 --zero=${my_zero}
      return 0
      else
       echo "You neet to provide a RDF and a Schema file"
      return 1
    fi
  }

  # check_existing_dir () {
  #     return 1
  # }
  # RUN_server () {
  #     echo "Dgraph server Starting ..."
  # }
  # RUN_BulkLoader () {
  #     echo "Dgraph BulkLoader Starting..."
  # }

  if check_existing_dir; then
    tell_him
    RUN_server
    else
    if RUN_BulkLoader; then
    RUN_server
    fi
  fi

exit
