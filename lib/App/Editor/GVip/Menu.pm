
package App::Editor::GVip::Menu;

use strict;
use Time::HiRes qw(gettimeofday tv_interval) ;
use Data::TreeDumper ;

#------------------------------------------------------------------------------------------------------

sub GetMenu
{
my ($window)  = @_ ;

my @menu_items = 
	(
	[ '/_File'             , undef        , undef          , 0 , '<Branch>' ],
	[ '/File/_New'         , '<control>N' , \&Menu_FileNew , 0 , '<StockItem>', 'gtk-new'],
	[ '/File/_Open'        , '<control>O' , \&Menu_FileOpen, 0 , '<StockItem>', 'gtk-open' ],
	[ '/_Edit'             , undef        , undef          , 0 , '<Branch>' ],
	[ '/_Search'           , undef        , undef          , 0 , '<Branch>' ],
	[ '/_View'             , undef        , undef          , 0 , '<Branch>' ],
	[ '/_Tools'            , undef        , undef          , 0 , '<Branch>' ],
	[ '/_Preferences'      , undef        , undef          , 0 , '<Branch>' ],
	[ '/_Preferences/Font' , undef        , undef          , 0 , '<Item>' ],
	) ;

# shortcuts
my $accelerator = undef ;
# doesn't work yet
#~ $accelerator = Gtk2::acceleratorGroup->new() ;

my $item_factory = Gtk2::ItemFactory->new("Gtk2::MenuBar" ,"<main>") ;
$item_factory->create_items($window, @menu_items) ;

my $menubar = $item_factory->get_widget("<main>") ;

return($menubar, $accelerator) ;
}

#------------------------------------------------------------------------------------------------------

sub Menu_FileNew
{
my ($window, $callback_action, $widget) = @_ ;

$window->AddView() ;
}

#------------------------------------------------------------------------------------------------------

sub Menu_FileOpen
{
my ($window, $callback_action, $widget) = @_ ;

my $file_dialog = Gtk2::FileSelection->new( "title" ) ;

#~ $file_dialog->set_filename( 'penguin.png' ) ;
$file_dialog->run() ;

#~ DisplayMessage($window, $file_dialog->get_filename()) ;
if(-e $file_dialog->get_filename())
	{
	my $tab = $window->AddView($file_dialog->get_filename()) ;
	$window->ShowTab($tab) ;
	}

$file_dialog->destroy() ;

#~ [04:22] <muppet>   $dialog = new dialog blah blah blah;
#~ [04:22] <muppet>    while ('ok' eq $dialog->run) {
#~ [04:22] <muppet>      $filename = $dialog->get_filename;
#~ [04:22] <muppet>      last if (filename_is_good ($filename));
#~ [04:22] <muppet>    }
#~ [04:23] <muppet>    $dialog->destroy;
} 

1 ;