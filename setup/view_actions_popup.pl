
use strict;
use warnings ;

use Data::TreeDumper ;
use Data::TreeDumper::Renderer::GTK ;

#------------------------------------------------------------------------------------------------------

sub Init
{
my ($view) = @_ ;
my ($buffer, $actions) = ($view->GetBuffer(), $view->GetActions()) ;

$actions->RegisterActions([ 'popup menu' => 'POPUP_MENU', '000' => \&ShowPopupMenu]) ;
}

#------------------------------------------------------------------------------------------------------

sub ShowPopupMenu
{
my ($actions, $view, $event)  = @_ ;

my $InsertSomething = sub {$view->{BUFFER}->Insert("Inserting Something") ; $view->UpdateDisplay() ;} ;

my @menu_items = 
	(
	[ '/_File'             , undef        , undef           , 0 , '<Branch>' ],
	[ '/File/_New'         , '<control>N' , undef           , 0 , '<StockItem>', 'gtk-new'],
	[ '/File/_Open'        , '<control>O' , $InsertSomething , 0 , '<StockItem>', 'gtk-open' ],
	[ '/InsertSomething'   , undef        , $InsertSomething, 0 , '<Item>', undef ],
	) ;

my $item_factory = Gtk2::ItemFactory->new("Gtk2::Menu" ,"<popup>") ;
$item_factory->create_items($view->{TEXT_AREA}->get_toplevel, @menu_items) ;

my $menu = $item_factory->get_widget("<popup>") ;

$menu->popup(undef, undef, undef, undef, $event->button, $event->time) ;
}

#------------------------------------------------------------------------------------------------------

1 ;