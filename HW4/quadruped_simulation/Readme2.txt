Es3:

MAIN.m è stato modificato come richiesto dalla traccia. Infine una sezione dedicata ai plot è stata aggiunta, chiamante le funzioni plotGaitDiagram e myplot, implementate.

runAllGaits.m ha il compito di runnare 6 simulazioni, una con ognuno dei gait disponibili, con i valori impostati. Essa chiama 6 volte main_iterated, una versione adattata a function del file MAIN.m fornito. Il plot si basa su plotGaitDiagram e myplot_iterated , funzione implementata a partire da quella precedentemente descritta, ai fini di mostrare i dati ritenuti sensibili nel paragone dei diversi gait. Finally, fig_animate_iterated is a version of the function to generate animation, in order to call it properly and show gaits during plot generation.

Se si vuole testare una traiettoria singolarmente, runnare MAIN.m.
Se si vuol testare tutti i gait con un particolare set di parametri, runnare runAllGaits.m

