package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"strconv"
	"time"

	g "github.com/soniah/gosnmp"
)

/**
https://support.messagesystems.com/docs/web-momo4/snmp-mib.php
	0: domain name
	1: receptions
	2: failures
	3: deliveries
	4: transient failures
	5: outbound connections
	6: active queue size
	7: delayed queue size
**/

const baseOID = "1.3.6.1.4.1.19552.1.2."
const versionOID = "1.3.6.1.4.1.19552.1.1.2"

func main() {
	domainVal := flag.String("domain", "gmail.com", "The domain to generate OID for. Like gmail.com or comcast.net")
	hostVal := flag.String("host", "", "IP address of Momentum server to query")
	portVal := flag.String("port", "8162", "SNMP port")
	flag.Parse()

	if *domainVal == "" {
		fmt.Println("Domain is a required field\n\n ")
		flag.PrintDefaults()
		os.Exit(1)
	}

	fmt.Printf("Domain: %s\n", *domainVal)
	domainStr := *domainVal

	decDomain := ""
	lookup := make(map[string]string)

	decDomain = fmt.Sprintf("%d", len(domainStr))

	for i := 0; i < len(domainStr); i++ {
		decDomain = fmt.Sprintf("%s.%d", decDomain, domainStr[i])
	}

	fmt.Printf("OID: %s\n", decDomain)

	lookup["."+versionOID] = "version"

	domainOID := fmt.Sprintf("%s%s.0.1", baseOID, decDomain)
	lookup["."+domainOID] = "domain_name"
	fmt.Printf("Domain Name: \n\t%s\n", domainOID)

	receptionsOID := fmt.Sprintf("%s%s.1.1", baseOID, decDomain)
	lookup["."+receptionsOID] = "receptions"
	fmt.Printf("Receptions: \n\t%s\n", receptionsOID)

	failuresOID := fmt.Sprintf("%s%s.2.1", baseOID, decDomain)
	lookup["."+failuresOID] = "failures"
	fmt.Printf("Failures: \n\t%s\n", failuresOID)

	deliveriesOID := fmt.Sprintf("%s%s.3.1", baseOID, decDomain)
	lookup["."+deliveriesOID] = "deliveries"
	fmt.Printf("Deliveries: \n\t%s\n", deliveriesOID)

	transientFailuresOID := fmt.Sprintf("%s%s.4.1", baseOID, decDomain)
	lookup["."+transientFailuresOID] = "transient_failures"
	fmt.Printf("Transient Failures: \n\t%s\n", transientFailuresOID)

	outConnectionsOID := fmt.Sprintf("%s%s.5.1", baseOID, decDomain)
	lookup["."+outConnectionsOID] = "out_connections"
	fmt.Printf("Out Connections: \n\t%s\n", outConnectionsOID)

	activeQueueSizeOID := fmt.Sprintf("%s%s.6.1", baseOID, decDomain)
	lookup["."+activeQueueSizeOID] = "active_queue"
	fmt.Printf("Active Queue Size: \n\t%s\n", activeQueueSizeOID)

	delayedQueueSizeOID := fmt.Sprintf("%s%s.7.1", baseOID, decDomain)
	lookup["."+delayedQueueSizeOID] = "delayed_queue"
	fmt.Printf("Delay Queue Size: \n\t%s\n", delayedQueueSizeOID)

	if *hostVal == "" {
		return
	}

	port, _ := strconv.ParseUint(*portVal, 10, 16)
	params := &g.GoSNMP{
		Target:    *hostVal,
		Port:      uint16(port),
		Community: "public",
		Version:   g.Version2c,
		Timeout:   time.Duration(10) * time.Second,
		Retries:   4,
		MaxOids:   3,
		//Logger:    log.New(os.Stdout, "", 0), // Uncomment for more logging
	}

	fmt.Printf("\n\nSNMP Query: %s:%s\n-------------\n", *hostVal, *portVal)

	err := params.Connect()
	if err != nil {
		log.Fatalf("Connect() err: %v", err)
	}
	defer params.Conn.Close()

	oids1 := []string{
		versionOID,
	}

	oids2 := []string{
		domainOID,
		receptionsOID,
		failuresOID,
	}

	oids3 := []string{
		deliveriesOID,
		transientFailuresOID,
		outConnectionsOID,
	}

	oids4 := []string{
		activeQueueSizeOID,
		delayedQueueSizeOID,
	}

	doQuery(params, oids1, lookup)
	doQuery(params, oids2, lookup)
	doQuery(params, oids3, lookup)
	doQuery(params, oids4, lookup)
}

func doQuery(params *g.GoSNMP, oids []string, lookup map[string]string) {
	result, err2 := params.Get(oids)
	if err2 != nil {
		log.Fatalf("Get() err: %v", err2)
	}

	for _, variable := range result.Variables {
		oidName := variable.Name
		if lookup[variable.Name] != "" {
			oidName = lookup[variable.Name]
		}

		fmt.Printf("%s = ", oidName)

		switch variable.Type {
		case g.OctetString:
			fmt.Printf("%s\n", string(variable.Value.([]byte)))
		default:
			fmt.Printf("%d\n", g.ToBigInt(variable.Value))
		}
	}
}
