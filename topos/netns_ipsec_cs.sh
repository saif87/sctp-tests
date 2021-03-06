source "$ROOTDIR/topos/netns.sh"

st_topo_setup()
{
	local def_opt="proto esp spi 0x1000 mode transport enc blowfish ipv6readylogo3descbc1to2 auth hmac\(sha1\) ipv6readylogsha11to2 | \
			proto esp spi 0x2000 mode transport enc blowfish ipv6readylogo3descbc2to1 auth hmac\(sha1\) ipv6readylogsha12to1"
	local ipsec_opt=${Topo_opt:-"$st_ipsec_opt"}

	ipsec_opt=${ipsec:-"$def_opt"}

	st_c_eth=(eth1 eth2)
	st_s_eth=(eth1 eth2)

	st_c_ip6=(2000::1 1000::1)
	st_s_ip6=(2000::2 1000::2)
	st_c_ip4=(192.0.0.1 172.0.0.1)
	st_s_ip4=(192.0.0.2 172.0.0.2)

	st_netns_ns_create c s
	st_netns_veth_create c "${st_c_eth[*]}" s "${st_s_eth[*]}"

	st_netns_addr_assign c "${st_c_eth[*]}" "${st_c_ip4[*]}" "24 16"
	st_netns_addr_assign s "${st_s_eth[*]}" "${st_s_ip4[*]}" "24 16"
	st_netns_addr_assign c "${st_c_eth[*]}" "${st_c_ip6[*]}" "64 128"
	st_netns_addr_assign s "${st_s_eth[*]}" "${st_s_ip6[*]}" "64 128"

	st_netns_ipsec_create c "${st_c_ip4[*]}" "${st_s_ip4[*]}" \
		   "$ipsec_opt" "${st_c_ip4[*]}" "${st_s_ip4[*]}" "out"
	st_netns_ipsec_create c "${st_c_ip6[*]}" "${st_s_ip6[*]}" \
		   "$ipsec_opt" "${st_c_ip6[*]}" "${st_s_ip6[*]}" "out"
	st_netns_ipsec_create s "${st_c_ip4[*]}" "${st_s_ip4[*]}" \
		   "$ipsec_opt" "${st_c_ip4[*]}" "${st_s_ip4[*]}" "in"
	st_netns_ipsec_create s "${st_c_ip6[*]}" "${st_s_ip6[*]}" \
		   "$ipsec_opt" "${st_c_ip6[*]}" "${st_s_ip6[*]}" "in"
}

st_topo_clean()
{
	st_netns_ipsec_destroy c
	st_netns_ipsec_destroy s
	st_netns_ns_destroy c s
}
