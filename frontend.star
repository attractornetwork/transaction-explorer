def run(plan, cfg, stack_info):
    title = cfg["TITLE"]
    chain_id = cfg["COMMON"]["chain_id"]
    l1_explorer = cfg["COMMON"]["l1_explorer"]
    swap_url = cfg["COMMON"].get("swap_url")
    backend_exposed = cfg["COMMON"].get("backend_exposed", False)

    service_port = cfg["PORT"]
    service_port_name = cfg["PORT_NAME"]
    service_ip = cfg["IP"]
    service_name = cfg["NAME"]
    service_image = cfg["IMAGE"]

    api_host = stack_info["api_host"]
    api_port = str(stack_info["api_port"])
    if backend_exposed:
        api_host = service_ip
        api_port = str(backend_exposed)

    env_vars = {
        "PORT": str(service_port),
        ## Blockchain configuration.
        # https://github.com/blockscout/frontend/blob/main/docs/ENVS.md#blockchain-parameters
        "NEXT_PUBLIC_NETWORK_NAME": "Attractor",
        "NEXT_PUBLIC_NETWORK_SHORT_NAME": "Attractor",
        ## TODO: add import from config
        "NEXT_PUBLIC_IS_TESTNET": "true",
        "NEXT_PUBLIC_NETWORK_ID": str(chain_id),

        ## Gas native coin configuration
        "NEXT_PUBLIC_NETWORK_CURRENCY_NAME": "Attractor",
        "NEXT_PUBLIC_NETWORK_CURRENCY_SYMBOL": "ATTRA",
        "NEXT_PUBLIC_NETWORK_CURRENCY_WEI_NAME": "Wei",
        "NEXT_PUBLIC_NETWORK_CURRENCY_DECIMALS": "18",
        "NEXT_PUBLIC_NETWORK_TOKEN_STANDARD_NAME": "ERC",

        ## Gas ERC-20 token configuration
        "NEXT_PUBLIC_NETWORK_SECONDARY_COIN_SYMBOL": "ATTRA",
        "NEXT_PUBLIC_NETWORK_MULTIPLE_GAS_CURRENCIES": "true",

        ## UI configuration
        # https://github.com/blockscout/frontend/blob/main/docs/ENVS.md#ui-configuration
        ### Homepage configuration
        "NEXT_PUBLIC_HOMEPAGE_HERO_BANNER_CONFIG": json.encode({
            "background": [
                "radial-gradient(ellipse at center, #3a1c71 0%, #d76d77 100%), #fff",  # светлая тема
                "radial-gradient(ellipse at center, #1a002b 0%, #0a001a 100%), #0a001a"  # тёмная тема
            ],
            "text_color": [
                "#1a002b",
                "#DCFE76"
            ]
        }),
        ### Navigation configuration
        "NEXT_PUBLIC_NETWORK_LOGO": str("https://storage.googleapis.com/blockchain-networks/static/attra/chain.png"),
        "NEXT_PUBLIC_NETWORK_LOGO_DARK": str("https://storage.googleapis.com/blockchain-networks/static/attra/chain.png"),
        "NEXT_PUBLIC_NETWORK_ICON": str("https://storage.googleapis.com/blockchain-networks/static/attra/chain-small.png"),
        "NEXT_PUBLIC_NETWORK_ICON_DARK": str("https://storage.googleapis.com/blockchain-networks/static/attra/chain-small.png"),
        
        # TODO: configure links (footer, header, others)

        ### Favicon configuration
        "FAVICON_MASTER_URL": str("https://storage.googleapis.com/blockchain-networks/static/attra/chain-small.png"),

        ### Metadata configuration
        "NEXT_PUBLIC_PROMOTE_BLOCKSCOUT_IN_TITLE": "false",
        "NEXT_PUBLIC_OG_DESCRIPTION": "Attractor is a blockchain explorer for the Attractor network.",

        # https://github.com/blockscout/frontend/blob/main/docs/ENVS.md#rollup-chain
        "NEXT_PUBLIC_ROLLUP_TYPE": "zkEvm",
        "NEXT_PUBLIC_ROLLUP_L1_BASE_URL": l1_explorer,
        # https://github.com/blockscout/frontend/blob/main/docs/ENVS.md#transaction-interpretation
        "NEXT_PUBLIC_TRANSACTION_INTERPRETATION_PROVIDER": "blockscout",
        ## API configuration.
        # https://github.com/blockscout/frontend/blob/main/docs/ENVS.md#api-configuration
        "NEXT_PUBLIC_API_PROTOCOL": "https",
        "NEXT_PUBLIC_API_HOST": "explorer.testnet.attra.me",
        "NEXT_PUBLIC_API_WEBSOCKET_PROTOCOL": "wss",
        "NEXT_PUBLIC_USE_NEXT_JS_PROXY": "false",
        # https://github.com/blockscout/frontend/blob/main/docs/ENVS.md#blockchain-statistics
        "NEXT_PUBLIC_STATS_API_HOST": "https://explorer.testnet.attra.me/stats-api",
        # https://github.com/blockscout/frontend/blob/main/docs/ENVS.md#solidity-to-uml-diagrams
        "NEXT_PUBLIC_VISUALIZE_API_HOST": "https://explorer.testnet.attra.me/visualize-api",
        # https://github.com/blockscout/frontend/blob/main/docs/ENVS.md#app-configuration
        "NEXT_PUBLIC_APP_PROTOCOL": "https",
        "NEXT_PUBLIC_APP_HOST": "explorer.testnet.attra.me",
        ## Remove ads.
        # https://github.com/blockscout/frontend/blob/main/docs/ENVS.md#banner-ads
        "NEXT_PUBLIC_AD_BANNER_PROVIDER": "none",
        # https://github.com/blockscout/frontend/blob/main/docs/ENVS.md#text-ads
        "NEXT_PUBLIC_AD_TEXT_PROVIDER": "none",

        # TODO: add bridge links
        # https://github.com/blockscout/frontend/blob/main/docs/ENVS.md#bridged-tokens
    }
    if swap_url:
        swap_item = {"text": "Attractor Bridge", "icon": "swap", "url": swap_url}
        env_vars["NEXT_PUBLIC_DEFI_DROPDOWN_ITEMS"] = json.encode([swap_item])

    service = plan.add_service(
        name=service_name,
        config=ServiceConfig(
            image=service_image,
            ports={
                service_port_name: PortSpec(
                    service_port, application_protocol="http", wait="5m"
                ),
            },
            public_ports={
                service_port_name: PortSpec(
                    service_port, application_protocol="http", wait="5m"
                ),
            },
            env_vars=env_vars,
        ),
    )
