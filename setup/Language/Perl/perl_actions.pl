
use strict;
use warnings ;

use Data::TreeDumper ;
use Data::TreeDumper::Renderer::GTK ;

#------------------------------------------------------------------------------------------------------

sub Init
{
my ($view) = @_ ;
my ($buffer, $actions) = ($view->GetBuffer(), $view->GetActions()) ;

$actions->RegisterActions( [ 'Pick Color' => 'C', 'C0S' => \&PickColor]) ;
}

#------------------------------------------------------------------------------------------------------

use Glib qw(TRUE FALSE);

sub PickColor
{
my ($actions, $view, $buffer, $key, $modifiers) = @_ ;

my $dialog = Gtk2::ColorSelectionDialog->new ("Changing color");

#~ $dialog->set_transient_for ($window);
#~ $dialog->set_transient_for($view->{TEXT_AREA}->window);

my $color = Gtk2::Gdk::Color->new (0, 65535, 0);

my $colorsel = $dialog->colorsel;

$colorsel->set_previous_color($color);
$colorsel->set_current_color($color);
$colorsel->set_has_palette(TRUE);

my $response = $dialog->run;

if ($response eq 'ok') 
	{
	$color = $colorsel->get_current_color;
	
	#~ $da->modify_bg ('normal', $color);
	}

$dialog->destroy;
}

#------------------------------------------------------------------------------------------------------
1 ;