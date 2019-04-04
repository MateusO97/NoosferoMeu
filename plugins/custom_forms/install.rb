# Make sure Noosfero's Debian Repository is included on your source.list
# Check it out: http://download.noosfero.org/debian/

#FIXME The package is not working
unless(system 'gem list -i chartkick')
<<<<<<< HEAD
  system 'gem install chartkick -v 2.3.5'
=======
  system "gem install chartkick -v '~> 2.3.5'"
>>>>>>> 665da0dcfc5511df2640d5fc0032b57a1856b3fb
end
