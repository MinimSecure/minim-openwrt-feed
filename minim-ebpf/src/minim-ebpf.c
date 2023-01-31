#include <uapi/linux/bpf.h>
#include <uapi/linux/if_ether.h>
#include <uapi/linux/if_packet.h>
#include <uapi/linux/ip.h>
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_legacy.h>

struct {
	__uint(type, BPF_MAP_TYPE_ARRAY);
	__type(key, u32);
	__type(value, long);
	__uint(max_entries, 256);
} my_map SEC(".maps");

struct {
	__uint(type, BPF_MAP_TYPE_ARRAY);
	__type(key, u32);
	__type(value, u8);
	__uint(max_entries, 256);
} minim_udp_ports SEC(".maps");

struct {
	__uint(type, BPF_MAP_TYPE_ARRAY);
	__type(key, u32);
	__type(value, u8);
	__uint(max_entries, 256);
} minim_tcp_ports SEC(".maps");

SEC("socket1")
int bpf_prog1(struct __sk_buff *skb)
{
	int index = load_byte(skb, ETH_HLEN + offsetof(struct iphdr, protocol));
	long *value, init_val = 1;

#if 0
	if (skb->pkt_type != PACKET_OUTGOING)
		return 0xffff;
#endif

	value = bpf_map_lookup_elem(&my_map, &index);
	if (value)
		__sync_fetch_and_add(value, 1);
		//__sync_fetch_and_add(value, skb->len);
        else
                bpf_map_update_elem(&my_map, &index, &init_val, BPF_NOEXIST);

	if (index == 17) {
		return 0xffff;
	} else { 
		return 0;
	}
}
char _license[] SEC("license") = "GPL";
