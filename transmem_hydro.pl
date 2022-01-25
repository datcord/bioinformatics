#
#
#predict transmembrane positions on sequence based on Kyte-Doolitle hydroscale

@transmem_positions = (35,58,72,95,107,129,151,174,197,220,275,298,306,329); #given transmem positions
@regular_transmem = ();
@window_sequence = ();
@positive_hydro= (); 
$i = 0;
$j=0;
$TP=0;
$FP=0;
$TN=0;
$FN=0;

while(<>){
    if($_=~/^\s{5}(.*)/mg){
        $found_sequence=$1;
        $found_sequence=~s/\s//g;
        push @sequence_array,$found_sequence;
    }


    if ($_=~/^FT\s{3}TRANSMEM\s+(\d+)\s+(\d+)\s+(.*)\./m){
            my ( $start, $end ) = ( $1 - 1, $2 - 1 );
            my $length = $end - $start + 1;
            print("$start,$end");
        }
}

$sequence= join '',@sequence_array;
$seq_lenth = length($sequence);

%hyd =(
    R=>'-4.5',
    K=>'-3.9',
    N=>'-3.5',
    D=>'-3.5',
    Q=>'-3.5',
    E=>'-3.5',
    H=>'-3.2',
    P=>'-1.6',
    Y=>'-1.3',
    W=>'-0.9',
    S=>'-0.8',
    T=>'-0.7',
    G=>'-0.4',
    A=>'1.8',
    M=>'1.9',
    C=>'2.5',
    F=>'2.8',
    L=>'3.8',
    V=>'4.2',
    I=>'4.5' );

%avg_vals;

print "\nPlease give the window size: ";
$window_size =  <>;

while ($window_size % 2 == 0 || $window_size < 0 || $window_size > 21){
    print "Please type a valid window size:";
    $window_size =  <>;
}

while ($i <= length($sequence) - $window_size){
    $hydro_sum = 0;
    $hydro_avg = 0;
    for($j=$i;$j<=$i+$window_size;$j++){
        push @window_sequence,substr($sequence,$j,1);
    }
    for $element(@window_sequence){
        $hydro_sum += $hyd{$element};
    }

    $hydro_avg = $hydro_sum / $window_size;

    $avg_vals{$i} = $hydro_avg;

    @window_sequence = ();
    $i+=1;
}
#change filename by adding window size at the end of it before running the script
open(FH,'>',"results21.txt");

for $key(sort  { $a <=> $b } (keys %avg_vals)){
    print FH "$key  @avg_vals{$key}\n";
    if ($avg_vals{$key} > 0){
        push @positive_hydro,$key;
    }
}


for($i=0;$i<($#transmem_positions);$i+=2){
    for($j=@transmem_positions[$i];$j<=@transmem_positions[$i+1];$j++){
        push @regular_transmem,$j; 
    }
}

for($i=0;$i<$#regular_transmem;$i++){
    for($j=0;$j<$#positive_hydro;$j++){
        if(@regular_transmem[$i] == @positive_hydro[$j]){
            $TP+=1;
        }
        if((@regular_transmem[$i] != @positive_hydro[$j]) && $j==$#positive_hydro-1){
            $FN+=1;
        }
    }
}

for($i=0;$i<$#positive_hydro;$i++){
    for($j=0;$j<$#regular_transmem;$j++){
        if((@positive_hydro[$i] != @regular_transmem[$j]) && $j==$#regular_transmem-1){
            $FP+=1;
        }
    }
}

$flag = 0; # used for checking if already found
for($i=0;$i<$seq_lenth;$i++){
    for($j=0;$j<$#positive_hydro;$j++){
        if($i == @positive_hydro[$j]){
            $flag = 1;
            last;
        }
    }
    if($flag != 1){
        for($j=0;$j<$#regular_transmem;$j++){
            if($i == @regular_transmem[$j]){
                $flag=1;
                last;
            }
        }
    }
    if($flag==0){
        $TN+=1;
    }
    $flag = 0;
}

print "FP:$FP, TN:$TN, FN:$FN, TP:$TP\n";
$AC = ($TP+$TN) / ($TP+$FP+$TN+$FN);
$MAT = (($TP*$TN) - ($FP*$FN)) / sqrt(($TP+$FP)*($TP+$FN)*($TN+$FP)*($TN+$FN));
print "Result: Accuracy: $AC, MCC: $MAT\n";
