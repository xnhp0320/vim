#!/usr/bin/perl
use v5.24;
use strict;
use warnings;
use File::Basename;
use Cwd qw(getcwd);

my $cwd = getcwd;
my $vim="https://github.com/vim/vim/archive/refs/tags/v8.2.4815.tar.gz";
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

if ( !-e "$vimdir/src/vim" && !-x "$vimdir/src/vim" ) {
    chdir $vimdir;
    my $pkgs = "
    apt-get install -y libncurses5-dev python-dev python3-dev libperl-dev git
    ";

    system("$pkgs") == 0 or die "fail to install pkgs: $?";

    my $conf = './configure \
    --with-features=huge \
    --enable-multibyte \
    --enable-pythoninterp=yes \
    --with-python-config-dir=/usr/lib/python2.7/config-x86_64-linux-gnu \
    --enable-python3interp=yes \
    --with-python3-config-dir=/usr/lib/python3.5/config-3.5m-x86_64-linux-gnu \
    --enable-perlinterp=yes \
    --enable-cscope \
    --prefix=/usr/local';

    system($conf) == 0 or die "configure vim fail: $?";
    system("make -j") == 0 or die "make vim fail: $?";
    system("make install") == 0 or die "make install vim fail: $?";
    chdir $cwd;
}

my $global_url = "https://ftp.gnu.org/pub/gnu/global/global-6.6.8.tar.gz";
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
