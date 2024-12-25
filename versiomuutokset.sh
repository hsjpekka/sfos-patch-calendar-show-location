#onko muutoksia
###
nimi="calendar-show-location"
#/usr/lib/qt5/qml/Sailfish/Calendar/
kaikki="
CalendarEventView.qml
"
#os-versio
if [ !$1 ] ; then
  sfversio=`grep -E '^VERSION_ID=' /etc/os-release | sed s/VERSION_ID=//`
else
  sfversio=$1
fi
#linkit paikattaviin tiedostoihin ovat orig-hakemistossa
lahtoh="./current"
#paikkoh-hakemistossa paikattavien tiedostojen versiot, joita paikan nykyinen versio koskee
paikkoh="./patch_orig"
#uusih-hakemistoon talletetaan arkistoinnin vuoksi nykyisen os-version paikattavat tiedostot, mikäli niitä on muutettu edellisestä os-versiosta
uusih="./orig_$sfversio"
###
echo "$nimi >>>>>>>>> >>>>>>>>>"
k=0
for tiedosto in $kaikki ; do
  tulos=`diff $lahtoh/$tiedosto $paikkoh/$tiedosto | wc -l`
  if [ $tulos > 0 ] ; then
    echo "$tiedosto muuttunut"
    k=1
  fi
done
#
#kopioi kaikki paikattavat tiedostot
if [ $k > 0 ] ; then
  if [ ! -d $uusih/ ] ; then
    echo "mkdir $uusih"
    mkdir $uusih
  fi
  if [ -d $paikkoh/ ] ; then
    echo "rm $paikkoh/*"
    rm $paikkoh/*
  fi
  for tiedosto in $kaikki ; do
    cp $lahtoh/$tiedosto $uusih
    cp $lahtoh/$tiedosto $paikkoh
  done
  tar -chf ${nimi}_orig.tar $lahtoh
fi
#
echo "$nimi <<<<<<<<< <<<<<<<<<"
