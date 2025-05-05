#!/usr/bin/perl
use v5.24;
use strict;
use warnings;
use File::Basename;
use Cwd qw(getcwd);
use Config;

my $cwd = getcwd;
my $vimversion = "v9.1.1365";
my $vim="https://github.com/vim/vim/archive/refs/tags/" . $vimversion . ".tar.gz";
my $vimtar = basename $vim;
if (!-e $vimtar) {
    system("wget $vim") == 0 or die "fail to wget vim: $?";
}

my $vimdir;
{
    $vimtar =~ /v(.*?)\.tar\.gz/;
    $vimdir = "vim-" . $1;
}

#print $vimtar, " ", $vimdir, "\n";

if (!-d $vimdir) {
    system("tar -xf $vimtar") == 0 or die "fail to uncompress vim: $?";
}

sub change_desert_color_scheme {
    my $path = $_[0];
    print $path, "\n";
    die "file not exist" if (!-e $path);
    do {
        local $^I = ".bak";
        local @ARGV = ($path);
        while (<>) {
            s/  hi Normal ctermfg=231(.*)/  hi Normal ctermfg=253$1/g;
            print;
        }
    }
}

sub change_desert_color_scehme_mac {
    change_desert_color_scheme "/usr/local/Cellar/vim/$vimversion/share/vim/vim82/colors/desert.vim";
}

sub change_desert_color_scheme_linux {
    change_desert_color_scheme "runtime/colors/desert.vim";
}

sub install_vim_mac {
    system("brew install vim") == 0 or die "fail to brew install";
    change_desert_color_scheme_mac();
}

sub install_vim_linux {
    if ( !-e "$vimdir/src/vim" && !-x "$vimdir/src/vim" ) {
        chdir $vimdir;
        my $pkgs = "
        apt-get install -y libncurses5-dev python-dev python3-dev libperl-dev git
        ";

        system("$pkgs") == 0 or die "fail to install pkgs: $?";

        # YouCompleteMe has already dropped support of Python2
        my $conf = './configure \
        --with-features=huge \
        --enable-multibyte \
        --enable-python3interp=yes \
        --with-python3-config-dir=/usr/lib/python3.5/config-3.5m-x86_64-linux-gnu \
        --enable-perlinterp=yes \
        --enable-cscope \
        --prefix=/usr/local';

        system($conf) == 0 or die "configure vim fail: $?";
        system("make -j") == 0 or die "make vim fail: $?";
        change_desert_color_scheme_linux();
        system("make install") == 0 or die "make install vim fail: $?";
        chdir $cwd;
    }
}

sub install_vim {
    if ($Config{osname} eq "darwin") {
        install_vim_mac();
    } elsif ($^O eq "linux") {
        install_vim_linux();
    }
}

install_vim;

my $global_url = "https://ftp.gnu.org/pub/gnu/global/global-6.6.14.tar.gz";
my $global_file = basename $global_url;

if (!-e $global_file) {
    system("wget $global_url") == 0 or die "fail to wget global:$!";
}
my $global_dir;

{
    $global_file =~ /(.*)\.tar\.gz/;
    $global_dir = $1;
}

if (!-d $global_dir) {
    system("tar xf $global_file") == 0 or die "fail to tar global:$!";
}

if (!-e "$global_dir/gtags/gtags" && !-x "$global_dir/gtags/gtags") {
    chdir $global_dir;
    system("./configure --prefix=/usr/local") == 0 or die "fail to configure global:$?";
    system("make -j; make install") == 0 or die "fail to make global:$?";
    chdir $cwd;
}

if (!-e $ENV{"HOME"} . "/.vim/autoload/plug.vim") {
    system("wget https://github.com/junegunn/vim-plug/archive/refs/tags/0.14.0.tar.gz");
    system("tar xzf 0.14.0.tar.gz");
    system("cp vim-plug-0.14.0/plug.vim ~/.vim/autoload/");
}

system("cp ./vimrc ~/.vimrc") if !-e "~/.vimrc";

my $home = $ENV{"HOME"};

if (!-e "$home/.vim/syntax/p4.vim" && !-e "$home/.vim/ftdetect/p4.vim") {
    system("mkdir -p ~/.vim/ftdetect");
    system("mkdir -p ~/.vim/syntax");
    system("echo \"au BufRead,BufNewFile *.p4      set filetype=p4\" >> ~/.vim/ftdetect/p4.vim");
    system("cp p4.vim ~/.vim/syntax");
}
