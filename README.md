# 👨‍💻 Solr7 garbage collector tuning

This is an example repo collecting best practises on GC tuning for
legacy Solr version 7.x.

## Tuning steps

1. Update Java to a [more recent JDK11](https://projects.eclipse.org/projects/adoptium.temurin/downloads).
   The Solr 7.x Docker image [uses JDK11 already](https://github.com/docker-solr/docker-solr/blob/master/7.7/Dockerfile#L2)
1. For heaps greater than `8g` activate the _G1 garbage collector_. In
   version 7.x, [the _Concurrent Mark Sweep collector_ is the default collector](https://github.com/apache/solr/blob/releases/lucene-solr/7.7.3/solr/bin/solr#L2007-L2021),
   which has been superseeded by the [G1 collector in Solr version 8.x](https://github.com/apache/solr/blob/releases/lucene-solr/8.8.1/solr/bin/solr#L2143-L2151).
1. Use `1/4` to `1/3` of the available machine heap as Java heap and leave
   the remaining gigabytes to the Linux machine disk cache.

## Implementing

All GC settings (as well as most other) can be applied via environment
variables or the [`solr.in.sh` file](https://github.com/apache/solr/blob/releases/lucene-solr/7.7.3/solr/bin/solr.in.sh).

The _G1_ collector can be tuned towards the maximum GC pauses it puts on the
running application. The configuration below allows a `200ms` pause every
`250ms`. These are settings you most likely want to tune.

```
# enable JMX analysis connections into the running process
ENABLE_REMOTE_JMX_OPTS=true

# Enable & tune G1GC
GC_TUNE=-XX:+UseG1GC \
    -XX:MaxGCPauseMillis=200 \
    -XX:GCPauseIntervalMillis=250 \
    -XX:+PerfDisableSharedMem \
    -XX:+ParallelRefProcEnabled \
    -XX:+UseLargePages \
    -XX:+AlwaysPreTouch \
    -XX:+ExplicitGCInvokesConcurrent \
    -XX:+UseNUMA \
    -XX:+UseStringDeduplication
```

You can see the available JVM flags and their defaults using

```
java -XX:+UnlockDiagnosticVMOptions -XX:+UnlockExperimentalVMOptions -XX:+PrintFlagsFinal -version
```

## Verifying

Verfiy that your system is stable and working using machine and Solr metrics.
Both can be collected via Prometheus and visualized via Grafana. For in-depth
details, use the [_Java Flight Recorder_](https://www.baeldung.com/java-flight-recorder-monitoring)
to create applications recordings.

1. Download the analysis UI, the [JDK Mission Control](https://jdk.java.net/jmc/8/) to your local machine.
1. Create a 60 second long JFR recording. Depending on you heap size and
   thread count, these can reach up to 500MB in size

```
# take the pid of the first java process as Solr pid
SOLR_PID=$(pgrep java)

jcmd ${SOLR_PID} JFR.start duration=60s filename=$(hostname)-$(date '+%Y-%m-%d_%H-%M-%S').jfr settings=profile
```

3. Transfer the recording file onto your local machine and open it
   using JDK Mission Control


### Further Reading

* https://bell-sw.com/announcements/2020/07/22/Hunting-down-code-hotspots-with-JDK-Flight-Recorder/
