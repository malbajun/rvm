if [ -n "$HOME" -a -d "$HOME" -a "$USER" != "root" ]; then
   export rvm_system_path="/usr/lib/rvm"
   export rvm_prefix="$HOME"
   export rvm_path="$HOME/.rvm"
   export rvm_user_install_flag=1
   export rvm_local_state_path="$rvm_path"

   mkdir -p "$rvm_path/config"
   set -- db known known_aliases known_strings md5 noask pre_commit.yml remote sha512
   for i; do
      if [ ! -L "$rvm_path/config/$i" -a -e "$rvm_system_path/config/$i" ]; then
         ln -rs "$rvm_system_path/config/$i" "$rvm_path/config/$i" 2>/dev/null
      fi
   done

   set -- tmp wrappers environments src archives rubies gems user log gemie
   for i; do
      mkdir -p "$rvm_path/$i"
   done

   set -- bin contrib docs examples gem-cache gemsets help hooks lib man patches patchsets scripts VERSION
   for i; do
      if [ ! -L "$rvm_path/$i" -a -e "$rvm_system_path/$i" ]; then
         ln -rs "$rvm_system_path/$i" "$rvm_path/$i"
      fi
   done
else
   export GEM_VENDOR="/var/cache/ruby/gemie/"
fi

[[ -s "$rvm_system_path/scripts/rvm" ]] && source "$rvm_system_path/scripts/rvm" # Load RVM into a shell session *as a function*
