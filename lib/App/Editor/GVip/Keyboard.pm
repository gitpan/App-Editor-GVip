
package App::Editor::GVip::View ;

use strict;
use Time::HiRes qw(gettimeofday tv_interval) ;
use Data::TreeDumper ;
use Text::Editor::Vip::Actions ;

#------------------------------------------------------------------------------------------------------

sub key_press_event
{
my($widget, $event, $view) = @_ ;

DoKeyboardAction($view, $event, $view->{BUFFER}, $view->{ACTIONS}) ;
UpdateDisplay($view) ;
}

#------------------------------------------------------------------------------------------------------

# use readable symboles
use Gtk2::Gdk::Keysyms ;

my %key_to_symbole = () ;
for my $key (keys %Gtk2::Gdk::Keysyms)
	{
	$key_to_symbole{$Gtk2::Gdk::Keysyms{$key}} = $key
	}

sub DoKeyboardAction
{
my ($view, $event, $buffer, $actions) = @_ ;

my $key = $event->keyval() ;
my $gtk_modifiers = $event->state() ;

my $modifiers = '' ;
$modifiers .= $gtk_modifiers =~ /control-mask/ ? 'C' : 0 ;
$modifiers .= $gtk_modifiers =~ /mod1-mask/ ? 'A' : 0 ;
$modifiers .= $gtk_modifiers =~ /shift-mask/ ? 'S' : 0 ;

# add filtering as in smed

my $key_symbole = $key_to_symbole{$key} ;

my $action_name = defined $key_symbole ? $key_symbole : $key ;
$action_name .= '-' . $modifiers ;

$key_symbole ||= 'no symbole' ;
print "Handling $key => '$key_symbole' + '$modifiers'.\n" ;

$actions->Run($action_name, $view, $buffer, chr($key), $modifiers) ;
}

#------------------------------------------------------------------------------------------------------

1 ;