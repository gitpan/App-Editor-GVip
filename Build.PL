
use strict ;
use warnings ;

use Module::Build;

my %all_modules ;
my @split_modules ;

my @pm_files = qw(
lib/App/Editor//GVip.pm

lib/App/Editor/GVip/View.pm
lib/App/Editor/GVip/Caret.pm
lib/App/Editor/GVip/Mouse.pm
lib/App/Editor/GVip/Keyboard.pm
lib/App/Editor/GVip/Draw.pm
lib/App/Editor/GVip/Menu.pm
lib/App/Editor/GVip/Scrollbars.pm
);

for(@pm_files)
	{
	$all_modules{$_} = $_ ;
	push @split_modules, $_ ;
	}

my @setup_lib=
qw(
setup/Colors/color_format.txt
setup/Colors/todo_colors
setup/Colors/x_colors.pm
setup/Colors/default_colors.pm
setup/default_settings.pl
setup/Language/Perl/Perl.pm
setup/Language/Perl/perl_actions.pl
setup/Language/Perl/PerlKeywords.pm
setup/Language/Perl/PerlColors.pm
setup/Language/Perl/SmedView.spl
setup/view_actions.pl
setup/view_actions_popup.pl
setup/Actions/default_actions.pl
) ;

for(@setup_lib)
	{
	$all_modules{$_} = "lib/App/Editor/GVip/$_" ;
	}

sub GetVersionAndRevisionFrom
{
my ($file) = @_ ;

my $version_from = File::Spec->catfile( split '/', $file );
my $version      = Module::Build->version_from_file($version_from);

if($ENV{'App_Editor_GVip_USE_GIT_VERSION_FOR_DIST'})
	{
	my $number_of_commits = `git log | grep -E 'commit [0-9a-f]{40}' | wc -l` ;
	chomp $number_of_commits ;
	
	if($number_of_commits)
		{
		#~ print "number of git revision $number_of_commits.\n" ;
		return("${version}.${number_of_commits}") ;
		}
	else
		{
		print "Couldn't get git revision, using version from '$file'!\n" ;
		return($version) ;
		}
	}
else
	{
	return($version) ;
	}
}

my $code = <<'EOC'

use strict ;
use warnings ;

sub GetVersionAndRevisionFrom
{
my ($file) = @_ ;

my $version_from = File::Spec->catfile( split '/', $file );
my $version      = Module::Build->version_from_file($version_from);

if($ENV{'App_Editor_GVip_USE_GIT_VERSION_FOR_DIST'})
	{
	my $number_of_commits = `git log | grep -E 'commit [0-9a-f]{40}' | wc -l` ;
	chomp $number_of_commits ;
	
	if($number_of_commits)
		{
		#~ print "number of git revision $number_of_commits.\n" ;
		return("${version}.${number_of_commits}") ;
		}
	else
		{
		print "Couldn't get git revision, using version from '$file'!\n" ;
		return($version) ;
		}
	}
else
	{
	return($version) ;
	}
}

sub ACTION_author_test
{
my $self = shift;
local $self->{properties}{test_files} = 'xt/author/*.t' ;
$self->SUPER::ACTION_test();
}

sub ACTION_dist
{
my $self = shift;

if($ENV{'App_Editor_GVip_USE_GIT_VERSION_FOR_DIST'})
	{
	my $have_git = $self->do_system('git --version');
	
	if($have_git)
		{
		print `git status -a`;
		
		if($self->do_system('git log  --decorate > git_Changes'))
			{
			use File::Copy;
			move('git_Changes', 'Changes') ;
			}
		else
			{
			print "Couldn't get git log, 'Changes' will not be generated from git log!\n" ;
			}
		}
	else
		{
		print "git not found, 'Changes' will not be generated from git log!\n" ;
		}
	}

$self->SUPER::ACTION_test() ;
#~ $self->ACTION_author_test() ;

$self->SUPER::ACTION_dist();
};

EOC
;

my $class = Module::Build->subclass(class => 'App::Editor::GVip', code => $code) ;

my $build = $class->new
	(
	module_name => 'App::Editor::GVip',
	
	dist_version => GetVersionAndRevisionFrom('lib/App/Editor/GVip.pm'),
	
	license => 'perl',
	build_requires => 
		{
		'Text::Diff' => 0,
		'Test::Block' => 0,
		'Test::Exception' => 0,
		'Test::NoWarnings' => 0,
		'Test::Warn' => 0,
		},
	requires => 
		{
		'Readonly'         => 0,
		'Sub::Exporter'     => 0,
		'Text::Editor::Vip' => 0,
		},
		
	pm_files     => \%all_modules,
	#~ autosplit    => \@split_modules,
	
	script_files => 'scripts/gvip',
	dist_author  => 'Nadim ibn hamouda el Khemir. <nkh@cpan.org>',
	dist_abstract => 'gnome interface to Text::Editor::Vip',
	);
	
$build->create_build_script;
  
