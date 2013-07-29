#Modul, welches die drei verwendeten Bewertungsfunktionen bereitstellt

#Funktion: gewichtete Sphaere:
sub sphere {
    my $return_value;
    for (my $i = 0; $i <= $#_; $i++) {
        my $temp = ($i + 1) * ($i + 1) * $_[$i] * $_[$i];
        $return_value += $temp;
    }
    return $return_value;
}

#Funktion: Rosenbrockfunktion:
sub rosenbrock {
    my $return_value;
    for (my $i = 0; $i <= ($#_ - 1); $i++) {
        my $temp = (100 * ((($_[$i] ** 2) - $_[$i + 1]) ** 2) ) + ((1 - $_[$i]) ** 2);
        $return_value += $temp;
    }
    
    return $return_value;
}

#Funktion: Rastriginfunktion
sub rastrigin {
    my $return_value;
    my $pi = 3.14159;
    for (my $i = 0; $i <= $#_; $i++) {
        my $temp = ( $_[$i] ** 2 ) - ( 10 * cos( 2 * $pi * $_[$i] ) );
        $return_value += $temp;
    }
    $return_value += 300;
    return $return_value;
}

return 1;     #Perl-intern notwendiger Rueckgabewert