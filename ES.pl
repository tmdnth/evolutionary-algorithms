#!C:/Setup/Perl/bin/perl -w

use strict;
use Math::Random;         #stellt normalverteilte Zufallszahlen bereit
use functions;            #stellt Bewertungsfunktionen bereit

srand();                  #Initialisierung des Zufallszahlengenerators

my $bewid = $ARGV[0] || 1;               #ID der Bewertungsfunktion
my $gens = $ARGV[1] || 2000;             #Anzahl Generationen(Standard: 2000)

my @eltvek = ((),(),(),(),(),(),(),());      #Vektor der aktuellen Elterngeneration

foreach my $i (0..7) {             #Initialisierung der Ausgangspopulation
    foreach(1..30) {
        push @{$eltvek[$i]}, rand(10) - 5;      #Koordinaten: zuf. Zahlen von -5 bis 5
    }
}

my $stab = 1;                       #Standardabweichung der normalverteilten Zufallszahlen

foreach my $genno (0..$gens) {                  #Berechne Evolution für $gens Generationen
    #Variablendefinitionen:
    my @kindvek;
    my @kindbewvek;
    my @kindbewvekalt;
    my @gesvek;
    my $erfolgsquotient = 0;
    my @bewvek;
    my $mittel;
    
    #Bewertung der aktuellen Elterngeneration
    foreach my $i (0..7) {
        my $tempbew = bewertung(@{$eltvek[$i]});
        $mittel += $tempbew;
        push @bewvek, $tempbew;
    }
    
    #Ausgabe der Generationsinformationen
    $mittel /= 8;
    my @bewveksort = sort {$a <=> $b} @bewvek;
    my $best = $bewveksort[0];
    
    print "\n=== Generation $genno ===\nDurchschnittliche Bewertung:\t$mittel\nBeste Bewertung:\t\t$best\n";
    
    #Selektion: Auswahl von 50 zufälligen Eltern
    foreach(1..50) {
        my @tempkind = @{$eltvek[int(rand(8))]};
        push @kindvek, \@tempkind;
    }
    
    #Rekombination: entfällt bei ES
    
    #Mutation: Addition von normalverteilten Zufallszahlen
    foreach my $j (0..49) {
        push @kindbewvekalt, bewertung(@{$kindvek[$j]});  #Bewertung der unmutierten Kinder
        foreach my $i (0..29) {
            ${$kindvek[$j]}[$i] += random_normal(1, 0, $stab); #Addiert normalverteilte ZZ's
        }
        push @kindbewvek, bewertung(@{$kindvek[$j]});     #Bewertung der mutierten Kinder
    }
    
    #Adaptive Schrittweitensteuerung:
    #Quotient erfolgreiche M./alle M.
    foreach(0..49) {
        if($kindbewvek[$_] < $kindbewvekalt[$_]) {$erfolgsquotient++;}
    }
    $erfolgsquotient /= 50;
    
    #Anpassung der Standardabweichung
    if($erfolgsquotient > 0.2 ) {$stab *= 1.22;}          #Konstanten nach Schwefel
    elsif($erfolgsquotient < 0.2) {$stab *= 0.82;}
    
    #Ersetzung: Verwendung der "+"-Variante
    #Ermitteln der 8 besten Individuen
    foreach(0..7) {
        my @tempvek = (\@{$eltvek[$_]}, $bewvek[$_]);
        push @gesvek, \@tempvek;
    }
    foreach(0..49) {
        my @tempvek = (\@{$kindvek[$_]}, $kindbewvek[$_]);
        push @gesvek, \@tempvek;
    }

    @gesvek = sort { ${$a}[1] <=> ${$b}[1] } @gesvek;
    
    #Ersetzen der alten Eltern
    @eltvek = ();
    for(0..7) {
        push @eltvek, \@{${$gesvek[$_]}[0]};
    }
}

#Auswahl der zu benutzenden Bewertungsfunktion
sub bewertung {
    my $ret_val;
    if($bewid == 1) {$ret_val = sphere(@_);}
    if($bewid == 2) {$ret_val = rosenbrock(@_);}
    if($bewid == 3) {$ret_val = rastrigin(@_);}
    return $ret_val;
}