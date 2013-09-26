#!/bin/sh
# Download: http://lists.apple.com/archives/scitech/2001/Jun/msg00016.html
# @(#) automan 1.0 Create Darwin man pages 6/11/01
#################################################
# a u t o m a n  -   Version 1.0  June 11, 2001 #
# - - - - - - - - - - - - - - - - - - - - - - - #
# This script creates unix man (help) pages for #
# Darwin/Mac OS X based on user input.          #
#                                               #
# Notes: 1. Make this script executable with:   #
#           chmod +x automan                    #
#        2. Usage:  ./automan                   #
#           For perfecting your man page, use:  #
#              ./automan < myapp.inp            #
#           where myapp.inp is a file which     #
#           contains your answers to automan's  #
#           pesky questions.                    #
#        4. sudo is used to install man pages.  #
#        5. This is wide-open source software.  #
#           Use and mutilate at your own risk.  #
# - - - - - - - - - - - - - - - - - - - - - - - #
# AUTHOR:   Craig A. Mattocks, PhD              #
#           Scientific Software Solutions, Inc. #
#           * Please contact the author at      #
#           <email@hidden>              #
#           with errors and suggestions.        #
#################################################

 ###################################################
# Set trap to abort on signal.  As per O'Reilly:  #
#                                                 #
# Signal   Number   Meaning and Typical Use       #
# ------   ------   -----------------------       #
#  HUP        1     Hang up - stop running.       #
#                   Sent when you log out or      #
#                   disconnect a modem.           #
#  INT        2     Interrupt - stop running.     #
#                   Sent when you type CTRL-c     #
#  QUIT       3     Quit - stop running (and      #
#                   dump core). Sent when you     #
#                   type CTRL-\                   #
#  KILL       9     Kill - stop unconditionally   #
#                   and immediately; a good       #
#                   "emergency kill."             #
#  TERM      15     Terminate - terminate nicely, #
#                   if possible.                  #
###################################################
trap 'echo " `basename $0`: Ouch. Dude! Ya fragged me." 1>&2; exit' 1 2 3 9 15

 ##############
# Greetings! #
##############
echo "-----------------------------------------------"
echo "                 a u t o m a n                 "
echo "                 - - - - - - -                 "
echo "A man (help) page generator for Darwin/Mac OS X"
echo "-----------------------------------------------"

 ############################
# Provide some motivation. #
############################
echo "You've worked hard to create your tool or app."
echo "It is essential that you document your work and"
echo "provide on-line help so others can build on your"
echo "efforts and take your app to the next level."
echo " "
echo "Please answer the following questions and I will"
echo "generate a unix man (help) page for your app."
echo " "
echo "Thank you for helping to make Darwin/Mac OS X the"
echo "most PHENOMENAL operating system on the planet!"
echo " "

 ###########################################
# Prompt user to obtain input parameters. #
###########################################
echo "-------"
echo "1. Name"
echo "-------"
echo "What is the name of your tool or app?"
echo -n "NAME> "
read name
echo " "

 echo "----------"
echo "2. Version"
echo "----------"
echo "Please provide a version number your app:"
echo -n "VERSION> "
read version
echo " "

 echo "---------"
echo "3. Author"
echo "---------"
echo "What is the author's name?"
echo -n "AUTHOR> "
read author
echo "and e-mail address?"
echo -n "EMAIL> "
read email
echo " "

 echo "----------"
echo "4. Purpose"
echo "----------"
echo "What is the purpose of your app?"
echo "Concise, like this:"
echo "PURPOSE> object transmorgrifying tool"
echo -n "PURPOSE> "
read purpose
echo " "

 echo "----------"
echo "5. Section"
echo "----------"
echo "Which section of the man pages is most appropriate for your app?"
echo "=================================================="
echo "| Category                               Section |"
echo "|------------------------------------------------|"
echo "| User commands                             1    |"
echo "| System calls                              2    |"
echo "| Library routines                          3    |"
echo "| I/O and special files                     4    |"
echo "| Administrative files                      5    |"
echo "| Games                                     6    |"
echo "| Miscellaneous commands                    7    |"
echo "| Administrative and maintenance commands   8    |"
echo "=================================================="
echo -n "SECTION> "
read section
while
   [ $section -lt 1 ] || [ $section -gt 8 ]
do
   echo "${section}: Huh? Lame answer. Try again:"
   echo -n "SECTION> "
   read section
done
echo " "

 echo "-----------"
echo "6. Synopsis"
echo "-----------"
echo "Please provide a one-line usage synopsis."
echo "Like this:"
echo "SYNOPSIS> transmorg [-xyz] [-cannotDie] [object ...] > file"
echo -n "SYNOPSIS> "
read synopsis
echo " "

 echo "--------------"
echo "7. Description"
echo "--------------"
echo "Please provide a description of your app"
echo "(use ^r <carat + r> to force line breaks):"
echo -n "DESCRIPTION> "
read description
echo " "

 echo "----------"
echo "8. Options"
echo "----------"
echo "Please list your app's options:"
echo " (1) each flag (without the - sign, I'll handle that) and"
echo " (2) a brief description of each option"
echo "Enter empty <RETURN> to end."
n=1
while :
do
   echo -n "OPTION      $n> "
   read flag
   case "$flag" in
      ?*) # COUNT AND STORE OPTION
          eval optf$n=$flag
          echo -n "DESCRIPTION $n> "
          read opt
          eval option$n='"$opt"'
          n=`expr $n + 1`
          ;;
      *)  # NO MORE OPTIONS
          echo "Options complete."
          break;;
   esac
done
echo " "

 echo "-----------"
echo "9. Examples"
echo "-----------"
echo -n "Want to provide some helpful examples? (Y/N): "
read ans
case "$ans" in
   [yY]|[yY][eE][sS]) # YES:
      echo "For each example, please provide:"
      echo " (1) a one-line command with proper syntax and"
      echo " (2) a brief explanation."
      echo "Enter empty <RETURN> to end."
      x=1
      while :
      do
         echo -n "EXAMPLE     $x> "
         read ex
         case "$ex" in
            ?*) # COUNT AND STORE EXAMPLE
                eval example$x='"$ex"'
                echo -n "EXPLANATION $x> "
                read exp
                eval explain$x='"$exp"'
                x=`expr $x + 1`
                ;;
             *) # NO MORE EXAMPLES
                echo "Examples complete."
                break;;
         esac
      done
      ;;
   [nN]|[nN][oO])     # NO:
      ;;
   *) echo "${ans}: Huh? Lame answer. Assuming you mean 'No'."
      ;;
esac
echo " "

 echo "--------"
echo "10. Bugs"
echo "--------"
echo -n "Ahem. Any bugs users should know about? (Y/N): "
read bugz
case "$bugz" in
   [yY]|[yY][eE][sS]) # YES:
      echo "Please describe bugs below:"
      echo "(use ^r <carat + r> to force line breaks):"
      echo "Enter empty <RETURN> to end."
      echo -n "BUGS> "
      read bugs
      ;;
   [nN]|[nN][oO])     # NO:
      ;;
   *) echo "${bugz}: Huh? Lame answer. Assuming you mean 'No bugs.'"
      ;;
esac
echo " "

 echo "--------------------"
echo "11. Cross references"
echo "--------------------"
echo "Are other man pages especially relevant to your app?"
echo "If so, list them with their sections like this:"
echo "SEE ALSO> chmod(1), symlink(7), sticky(8)"
echo -n "SEE ALSO> "
read seealso
echo " "
echo "Is there a web site for (or relevant to) your app?"
echo "If so, please provide its URL like this:"
echo "WEB SITE> http://www.doofus.com/slicedbread.html";
echo -n "WEB SITE> "
read Web site
echo " "

 echo "------------"
echo "12. Install?"
echo "------------"
echo -n "Want me to install your man page for you? (Y/N): "
read ins
echo " "

 ##########################
# Generate the man page. #
##########################
echo "... I am creating your man page ..."
echo " "

 d=`date +"%a, %B %e, %Y"`
bname=`echo $name | tr "a-z" "A-Z"`
sname=`echo $name | tr "A-Z" "a-z"`
dir="/usr/share/man/man$section/"
file="$sname.$section"

echo ".TH $bname $section \"v\ $version\" \"$d\" \"DARWIN\ \-\ MAC\ OS\ X\"" >> $file

 echo ".SH NAME" >> $file
echo ".B $name" >> $file
echo "\- $purpose" >> $file

 echo ".SH SYNOPSIS" >> $file
echo "$synopsis" >> $file
echo ".br" >> $file

 echo ".SH OPTIONS" >> $file
m=1
while [ $m -lt $n ]
do
   echo ".TP" >> $file
   eval echo .B "\-\$optf$m" >> $file
   eval echo "\$option$m" >> $file
   m=`expr $m + 1`
done

 echo ".SH DESCRIPTION" >> $file
echo $description | sed 's/\^r/\
.P\
/g' >> $file
echo ".br" >> $file

 case "$ans" in
   [yY]|[yY][eE][sS]) # YES:
      echo ".SH EXAMPLES" >> $file
      y=1
      while [ $y -lt $x ]
      do
         eval echo "Example $y:\ \ \$example$y" >> $file
         echo ".br" >> $file
         eval echo "\$explain$y" >> $file
         echo ".P" >> $file
         y=`expr $y + 1`
      done
      ;;
   [nN]|[nN][oO])     # NO:
      ;;
   *)                 # LAME ANSWER:
      ;;
esac

 case "$bugz" in
   [yY]|[yY][eE][sS]) # YES:
      echo ".SH BUGS" >> $file
      echo $bugs | sed 's/\^r/\
.P\
/g' >> $file
      ;;
   [nN]|[nN][oO])     # NO:
      ;;
   *)                 # LAME ANSWER:
      ;;
esac

 echo ".SH VERSION" >> $file
echo "This documentation describes" >> $file
echo ".B $name" >> $file
echo "version $version" >> $file

 echo '.SH "SEE ALSO"' >> $file
echo "$seealso" >> $file
echo ".br" >> $file
echo ".I $Web site" >> $file

 echo ".SH AUTHOR" >> $file
echo ".br" >> $file
echo ".B $author" >> $file
echo ".br" >> $file
echo ".I \<$email\>" >> $file

 #####################################
# Install the man page, if desired. #
#####################################
case "$ins" in
   [yY]|[yY][eE][sS]) # YES:
      echo "WARNING -- I will need sudo permission to install the man page."
      echo "Enter your USER (not ROOT) password if prompted."
      chmod 644 $file
      sudo chown root:wheel $file
      sudo cp -f $file $dir
      echo " "
      echo "Man page installed.  To view it, issue the command:"
      if [ $section -eq 1 ]
         then echo "man $name"
         else echo "man $section $name"
      fi
      ;;
   [nN]|[nN][oO])     # NO:
      echo "You have decided NOT to install your man page."
      ;;
   *) echo "${ins}: Huh? Lame answer. Man page NOT installed."
      ;;
esac
echo " "

 #########
# Ciao! #
#########
echo "-------------------------------------------------------------"
echo "a u t o m a n -- all done! Man page created in file $file"
echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "You can use man2html to convert your man page to a web page: "
echo "http://www.nacs.uci.edu/indiv/ehood/tar/man2html3.0.1.tar.gz "
echo "-------------------------------------------------------------"

 exit

