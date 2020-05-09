#include <core.p4>
#include <psa.p4>

struct EMPTY { };

header EMPTY_H {};

typedef bit<48>  EthernetAddress;

header ethernet_t {
    EthernetAddress dstAddr;
    EthernetAddress srcAddr;
    bit<16>         etherType;
}

parser MyIP(
    packet_in buffer,
    out ethernet_t eth,
    inout EMPTY b,
    in psa_ingress_parser_input_metadata_t c,
    in EMPTY_H d,
    in EMPTY_H e) {

    state start {
        buffer.extract(eth);
        transition accept;
    }
}

parser MyEP(
    packet_in buffer,
    out EMPTY a,
    inout EMPTY b,
    in psa_egress_parser_input_metadata_t c,
    in EMPTY d,
    in EMPTY_H e,
    in EMPTY_H f) {
    state start {
        transition accept;
    }
}

type bit<12> CounterIndex_t;

control MyIC(
    inout ethernet_t a,
    inout EMPTY b,
    in psa_ingress_input_metadata_t c,
    inout psa_ingress_output_metadata_t d) {

    Counter<bit<10>,CounterIndex_t>(1024, PSA_CounterType_t.PACKETS) counter;

    action execute() {
        counter.count((CounterIndex_t)1024);
    }

    table tbl {
        key = {
            a.srcAddr : exact;
        }
        actions = {
            NoAction;
            execute;
        }
    }

    apply {
        tbl.apply();
    }
}

control MyEC(
    inout EMPTY a,
    inout EMPTY b,
    in psa_egress_input_metadata_t c,
    inout psa_egress_output_metadata_t d) {
    apply { }
}

control MyID(
    packet_out buffer,
    out EMPTY_H a,
    out EMPTY_H b,
    out EMPTY c,
    inout ethernet_t d,
    in EMPTY e,
    in psa_ingress_output_metadata_t f) {
    apply { }
}

control MyED(
    packet_out buffer,
    out EMPTY_H a,
    out EMPTY_H b,
    inout EMPTY c,
    in EMPTY d,
    in psa_egress_output_metadata_t e,
    in psa_egress_deparser_input_metadata_t f) {
    apply { }
}

IngressPipeline(MyIP(), MyIC(), MyID()) ip;
EgressPipeline(MyEP(), MyEC(), MyED()) ep;

PSA_Switch(
    ip,
    PacketReplicationEngine(),
    ep,
    BufferingQueueingEngine()) main;