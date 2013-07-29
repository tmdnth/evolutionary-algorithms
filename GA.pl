#!C:/Setup/Perl/bin/perl -w

use strict;
use Math::Random;      #stellt normalverteilte Zufallszahlen bereit
use functions;         #stellt Bewertungsfunktionen bereit

srand();               #Initialisierung des Zufallszahlengenerators

my $bewid = $ARGV[0] || 1;               #ID der Bewertungsfunktion
my $gens = $ARGV[1] || 2000;             #Anzahl Generationen(Standard: 2000)

my @eltvek = ((),(),(),(),(),(),(),());

foreach my $i (0..7) {       #Initialisierung der Ausgangspopulation
    foreach(1..30) {
        push @{$eltvek[$i]}, rand(10) - 5;      #Koordinaten: zuf. Zahlen von -5 bis 5
    }
}

foreach my $genno (0..$gens) {               #Berechne $gens Generationen
    #Variablendefinitionen:
    my @bewvek;
    my @fitvek;
    my @paarvek;
    my @pvek;
    my @pvektemp;
    my $bewsum;
    my $fitsum;
    my $mittel;
    my @kindvek;
    my @ordervek;
    
    #Bewertung der aktuellen Generation
    foreach my $i (0..7) {
        my $tempbew = bewertung(@{$eltvek[$i]});
        push @bewvek, $tempbew;
        $mittel += $tempbew;
        $bewsum += $tempbew;
    }
    
    #Ausgeben der Generationsinformationen
    $mittel /= 8;
    my @bewveksort = sort {$a <=> $b} @bewvek;
    my $best = $bewveksort[0];
    
    print "\n=== Generation $genno ===\nDurchschnittliche Bewertung:\t$mittel\nBeste Bewertung:\t\t$best\n";
    
    #Ermittlung der Fitness = Gesamtbewertung / individuelle Bewertung
    foreach my $i (@bewvek) {
        push @fitvek, ($bewsum / $i);
        $fitsum += ($bewsum / $i);
    }
    
    #Ermittlung der Wahrscheinlichkeiten für Rekombination
    foreach my $i (@fitvek) {
        push((@pvek), ($i / $fitsum));
    }
    
    
    foreach my $i (0..7) {
        my $temp;
        for (my $j = 0; $j <= $i; $j++) {
            $temp += $pvek[$j];
        }
        push @pvektemp, $temp;
    }
    @pvek = @pvektemp;
    
    #Selektion: Paarbildung nach dem "Roulette"-Schema
    foreach my $pn (0..49) {
        push @paarvek, [];
        my $n = rand(1);
        my $m = rand(1);
        my $p1 = 0;
        my $p2 = 0;
        foreach my $i (0..7) {
            if($pvek[$i] >= $n) {$p1 = $i; last;}
        }
        foreach my $i (0..7) {
            if($pvek[$i] >= $m) {$p2 = $i; last;}
        }
        push @{$paarvek[$pn]}, \@{$eltvek[$p1]};
        push @{$paarvek[$pn]}, \@{$eltvek[$p2]};
    }   #Paarvektor enthaelt jetzt 50 Paare
    
    #Rekombination - Schema arithmetisches Mittel
    foreach my $i (0..49) {
        my @tempvek;
        foreach my $j (0..29) {
            my $temp = ${${$paarvek[$i]}[0]}[$j] + ${${$paarvek[$i]}[1]}[$j];
            $temp /= 2;
            push @tempvek, $temp;
        }
        $paarvek[$i] = \@tempvek;
    }   #Paarvek enthaelt jetzt 50 Kinder
    
    #Mutation: Vertauschen 2er zufälliger Koordinaten mit Isolierung in "Kindergarten"
    foreach my $i (0..49) {
        my @tempvek = @{$paarvek[$i]};
        foreach(1..10) {                  #Anzahl der Kindergartendurchlaeufe
                my $n = int(rand(30));
                my $m = int(rand(30));
                my $speicher = $tempvek[$n];
                $tempvek[$n] = $tempvek[$m];
                $tempvek[$m] = $speicher;
        }
        #Auswahl der Individuen, die sich durch "Kindergarten" verbessert haben
        if(bewertung(@tempvek) < bewertung(@{$paarvek[$i]})) {
            push @kindvek, \@tempvek;
        }
    }
    @kindvek = sort { bewertung(@{$a}) <=> bewertung(@{$b}) } @kindvek;
    
    #Ersetzung: Alle verfügbaren Kinder für neue Generation benutzen
    
    #Ermitteln einer zufälligen Reihenfolge der Eltern
    foreach my $i (0..7) {
        push @ordervek, $i;
    }
    foreach(1..100) {
        my $n = int(rand(8));
        my $m = int(rand(8));
        my $temp = $ordervek[$n];
        $ordervek[$n] = $ordervek[$m];
        $ordervek[$m] = $temp;
    }
    
    #Eltern ersetzen
    foreach my $i (0..7) {
        if($#kindvek < $i) {last;}
        $eltvek[$ordervek[$i]] = \@{$kindvek[$i]};
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