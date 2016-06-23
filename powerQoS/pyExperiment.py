#!/usr/bin/env python

__author__ = """ Stelios Sidiroglou-Douskos <stelios@csail.mit.edu> """

import sys, os, signal, time, datetime,subprocess
from optparse import OptionParser
import numpy
from pycpufreq import pycpufreq,messages,errors,cpuspeedy
import pyWattsup

def runSubprocessWithTimeout(arglist0, options, srcFile = None, destFile = None):
    arglist = [str(s) for s in arglist0]
    print "[runSubprocessWithTimeout] Command: ", " ".join(arglist)

    start = datetime.datetime.now()
    p = subprocess.Popen(arglist, stdin = srcFile, stdout = destFile, stderr = sys.stderr)
    while p.poll() is None:
        time.sleep(1)
        now = datetime.datetime.now()
        if (now -start).seconds > options.timeout:
            print "[TIMEOUT] Killing pid:%d" %p.pid
            os.kill(p.pid, signal.SIGKILL)
            os.waitpid(-1, os.WNOHANG)
            return
    endTime = (datetime.datetime.now() - start).seconds
    print "[runSubprocessTimeOut:%d]" %(endTime)


def amIRoot():
    return os.getuid() == 0

def setCPUspeed(options):
    for i in range(0, 8):
        cpufreq = pycpufreq.pycpufreq(cpu=i)
        cpufreq.status()
        #print cpufreq.dump()
       
        if not amIRoot():
            print "[-] You need to be root to change frequency!"
            sys.exit(1)

        if options.cpuspeed == "max":
            print "[+] Setting CPU:%d maximum CPU speed:%s" %(i,cpufreq.speed_max)
            cpufreq.setspeed(cpuspeedy.SPEED_MAX(cpufreq.speed_max))
        elif options.cpuspeed == "min":
            print "[+] Setting CPU:%d minimum CPU speed:%s" %(i,cpufreq.speed_min)
            cpufreq.setspeed(cpuspeedy.SPEED_MIN(cpufreq.speed_min))

def parseOptions():
    # parse command line options
    parser = OptionParser(usage = "usage: %prog [options]")
   
    parser.add_option("-v", "--verbose", dest="verbose",
                      action="store_true",  
                      help="Turn on extra logging information"
                      )
    
    parser.add_option("-r", "--repetitions", dest="repetitions",
                  action="store", type="int", default="1",
                  help="Number of repetitions for each experiment")    

    parser.add_option("-H", "--heartbeat-on", dest="heartbeat_on",
                  action="store_true", default=False,
                  help="Do we want heartbeat enabled instrumentation!?")
    
    parser.add_option("-T", "--timeout", dest="timeout",
                action="store", type="int", default="3600",
                help="Process timeout")
    
    parser.add_option("-p", "--perforation-rate", dest="perf_rate",
                action="store", type="float", default="0.5",
                help="Loop perforation rate")

    parser.add_option("-C", "--cpu-speed", dest="cpuspeed",
                action="store", type="string", default="nochange",
                help="Loop perforation rate")


        

    return parser

def main(user_args=None):
    parser = parseOptions()
    (options, args) = parser.parse_args(args=user_args)

    print os.getcwd()

    if len(args) != 2:
        print parser.error("You need to specify 2 options: example ids_to_perforate")
        sys.exit(1)

    example = args[0]
    ids     = args[1]

    # Set up watts up
    wattsup = pyWattsup.WattsUp("/dev/ttyUSB0", 115200 , verbose=options.verbose) 
    wattsup.serial.open()

    if options.cpuspeed != "nochange":
        setCPUspeed(options)
    
    
    #TODO: Where should I set the number of threads?

    arglist = ["./run.sh", "run_ref", example, options.repetitions, str(options.perf_rate)]

    '''
    arglist = ["./run.sh", "run_ref", example, ids, options.repetitions, str(options.perf_rate), \
                "0" if options.heartbeat_on else "1" ]
    ''' 
    startTime = datetime.datetime.now() 
    endTime = (datetime.datetime.now() - startTime).seconds

    wattsup.clearMemory()
    wattsup.logInternal(1)
    
    runSubprocessWithTimeout(arglist, options)
    #time.sleep(2)

    results = wattsup.getInternalData()
    wattsup.printStats(results)
    wattsup.serial.close()

    
if __name__ == "__main__":
    main()
 
    
