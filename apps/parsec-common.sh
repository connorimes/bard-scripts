case `uname -i` in
  armv7l) ARCH=arm
          ;;
  x86_64) ARCH=amd64
          ;;
  *) ARCH=x86
esac
