$/="\/\/\n";
@sequence_array = ();
@help_array = ();
@index_array = ();
$found_symbol = "M";
$not_found_symbol = "-";
$end_symbol = "//";

open(FH,'>',"protein_info.txt");


while (<>){
    if ($_=~/^ID\s{3}(.*?)\s+(.*?)\;\s+(\d+\sAA.)/m){
        $prot_info = $3;
        print FH ">$1";
    }
    if ($_=~/^AC\s{3}(.*?)\;/m){
        print FH "|$1";
    }
    if ($_=~/^SQ SEQUENCE\s+(.*?)\;/m){
        print FH "|$1|";
    }

    # remove spaces and special characters from protein info
    $prot_info =~ tr/A-Za-z0-9//cd;


    print FH "|$prot_info\n";

    while ($_=~/^\s{5}(.*)/mg){
        $sequence=$1;
        $sequence=~s/\s//g;
        push @sequence_array,$sequence;
    }

   

    while ($_=~/^FT\s{3}TRANSMEM\s+(\d+)\s+(\d+)\s+(.*)\./mg){
        $tmstart=$1; #first variable kept from the regex from first bracket (\d+)
        $tmend=$2; #second variable kept from the regex from second bracket (\d+)

        # push start and ending indices of protein to index array
        push @index_array,$tmstart,$tmend;

    }
    
    #get res_protein as single line string
    $res_protein = join '',@sequence_array;

    $j=0;

    for($i=0;$i<length($res_protein);$i++){
        
        if($i == $index_array[$j+1]){
            # check if i == limit and then move on to the next starting index
            $j = $j + 2;
            
        }
        #push "found" or "not found" symbol depending on whether we are in between the given limits or not
        if ($i >= $index_array[$j] && $i < $index_array[$j+1]){
            push @help_array,$found_symbol;
        }else{
            push @help_array,$not_found_symbol;
        }
    }
    
    # turn help_array into single line string 
    $res_diamembrane = join '',@help_array;

    # add the protein sequence to file
    print FH "$res_protein\n";

    # add M or - symbol and then end symbols to file 3rd and 4th line
    print FH "$res_diamembrane\n";

    print FH "$end_symbol\n";

    #clear all buffers to reset the process with the next input
    @sequence_array = ();
    @help_array = ();
    @index_array = ();

}