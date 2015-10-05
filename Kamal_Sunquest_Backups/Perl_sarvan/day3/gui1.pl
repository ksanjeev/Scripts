use Tk;
$mw = new MainWindow();
$b = $mw->Button(-text => "myButton",
	-command => sub { print "clicked" });
$b->pack();
MainLoop();
