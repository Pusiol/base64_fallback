#!/bin/bash

which od &>/dev/null || od() {
    local C O=0 W=16
    while IFS= read -r -d '' -n 1 C
    do
        (( O%W )) || printf '%07o' $O
        printf ' %02x' "'$C"
        (( ++O%W )) || echo
    done
    echo
}

base64() {
    awk \
        '
        function decode64() {
            b64="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
            while(getline < "/dev/stdin") {
                ll = length($0);
                for(ii = 0; ii < ll; ii++) {
                    stv = index(b64, substr($0, ii+1, 1));
                    if(stv--) {
                        for(bb = 0; bb < 6; ++bb) {
                            byte = byte*2+int(stv/32);
                            stv = (stv*2)%64;
                            if(++obc > 7) {
                                if (byte == 0){
                                    system("dd bs=1 count=1 < /dev/zero >> '\''tmp104'\'' ");
                                } else {
                                    printf "%c", byte >> "tmp104";
                                }
                                obc = 0;
                                byte = 0;
                            }
                        }
                    }
                }
            }
        }
        BEGIN {
            decode64();
        }' "$@"
}

base64 "$@"
mv tmp104 $1

