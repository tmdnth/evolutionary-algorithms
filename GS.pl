#!C:/Setup/Perl/bin/perl -w

use strict;
use Math::Random;         #stellt normalverteilte Zufallszahlen bereit
use functions;            #stellt Bewertungsfunktionen bereit

srand();

my $bewid = $ARGV[0] || 1;               #ID der Bewertungsfunktion
my $gens = $ARGV[1] || 2000;             #Anzahl Generationen(Standard: 2000)

my @eltvek = ((),(),(),(),(),(),(),());

foreach my $i (0..7) {       #Initialisierung der Ausgangspopulation
    foreach(1..30) {
        push @{$eltvek[$i]}, rand(10) - 5;    #Koordinaten: zuf. Zahlen von -5 bis 5
    }
}

my $stab = 1;         #Standardabweichung

foreach my $genno (0..$gens) {
    #Variablendefinitionen
    my @bewvek;
    my @fitvek;
    my @pvek;
    my @pvektemp;
    my @paarvek;
    my @kindvek;
    my @kindbewvek;
    my @kindbewvekalt;
    my @gesvek;
    my $erfolgsquotient = 0;
    my $mittel;
    my $bewsum;
    my $fitsum;
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
        push @fitvek, ($bewsum / $i);   # fitvek enthaelt jetzt Fitness != Bewertung! 
        $fitsum += ($bewsum / $i);
    }
    
    #Ermittlung der Wahrscheinlichkeiten für Rekombination
    foreach my $i (@fitvek) {
        push((@pvek), ($i / $fitsum));
    }
    
    #Vorbereitung auf Selektionsschema "Roulette": Aufsummieren der Wahrscheinlichkeiten
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
    }
    
    #Rekombination: Schema arithmetisches Mittel
    foreach my $i (0..49) {
        my @tempvek;
        foreach my $j (0..29) {
            my $temp = ${${$paarvek[$i]}[0]}[$j] + ${${$paarvek[$i]}[1]}[$j];
            $temp /= 2;
            push @tempvek, $temp;
        }
        $kindvek[$i] = \@tempvek;
    }
    
    #Mutation: Addition von normalverteilten Zufallszahlen
    foreach(0..49) {
        push @kindbewvekalt, bewertung(@{$kindvek[$_]});  #Bewertung der unmutierten Kinder
        foreach my $i (0..29) {
            ${$kindvek[$_]}[$i] += random_normal(1, 0, $stab); #Addiert normalverteilte ZZ's
        }
        push @kindbewvek, bewertung(@{$kindvek[$_]});     #Bewertung der mutierten Kinder
    }
    
    #Adaptive Schrittweitensteuerung:
    #Quotient erfolgreiche M./alle M.
    foreach(0..49) {
        if($kindbewvek[$_] < $kindbewvekalt[$_]) {$erfolgsquotient++;}
    }
    $erfolgsquotient /= 50;
    
    #Anpassung der Standardabweichung
    if($erfolgsquotient > 0.2 ) {$stab *= 1.22;}     #Konstanten nach Schwefel
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

    @gesvek = sort { ${$a}[1] <=> ${$b}[1] } @gesvek; #Nach Bewertung sortieren
    
    #Ersetzen der alten Eltern
    @eltvek = ();
    foreach my $i (0..7) {    #neuen Elternvektor erzeugen = 8 Beste aus @gesvek
        push @eltvek, \@{${$gesvek[$i]}[0]};
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