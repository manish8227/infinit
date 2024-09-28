export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    echo
    source "$NVM_DIR/nvm.sh"
else
    show "NVM not found, installing NVM..."
    echo
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
    source "$NVM_DIR/nvm.sh"
fi


echo
nvm install 22 && nvm alias default 22 && nvm use default

echo
curl -L https://foundry.paradigm.xyz | bash
export PATH="$HOME/.foundry/bin:$PATH"
sleep 5
source ~/.bashrc
foundryup

echo
curl -fsSL https://bun.sh/install | bash
export PATH="$HOME/.bun/bin:$PATH"
sleep 5
source ~/.bashrc

echo
mkdir infinit-tech && cd infinit-tech
bun init -y
bun add @infinit-xyz/cli

echo
bunx infinit init
bunx infinit account generate
echo

read -p "Confirm your wallet address (Match the address from the step above) : " WALLET
echo
read -p "Confirm your account ID (Recall in the step above) : " ACCOUNT_ID
echo

show "Keep this private key somewhere safe, you'll be neediing this in future"
echo
bunx infinit account export $ACCOUNT_ID

sleep 5


echo
bun init -y
bun add @infinit-xyz/cli

echo
bunx infinit init

echo
# Removing old deployUniswapV3Action script if exists
rm -rf src/scripts/deployUniswapV3Action.script.ts

cat <<EOF > src/scripts/deployUniswapV3Action.script.ts
import { DeployUniswapV3Action, type actions } from '@infinit-xyz/uniswap-v3/actions'
import type { z } from 'zod'

type Param = z.infer<typeof actions['init']['paramsSchema']>

// TODO: Replace with actual params
const params: Param = {
  // Native currency label (e.g., ETH)
  "nativeCurrencyLabel": 'ETH',

  // Address of the owner of the proxy admin
  "proxyAdminOwner": '$WALLET',

  // Address of the owner of factory
  "factoryOwner": '$WALLET',

  // Address of the wrapped native token (e.g., WETH)
  "wrappedNativeToken": '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2'
}

// Signer configuration
const signer = {
  "deployer": "$ACCOUNT_ID"
}

export default { params, signer, Action: DeployUniswapV3Action }
EOF

show "Executing the UniswapV3 Action script..."
echo
bunx infinit script execute deployUniswapV3Action.script.ts

sleep 7

echo
# Removing old deployUniswapV3Action script if exists
rm -rf src/scripts/deployInfinitErc20Action.script.ts

cat <<EOF > src/scripts/deployInfinitErc20Action.script.ts

import { DeployInfinitERC20Action, type actions } from '@infinit-xyz/token/actions'
import type { z } from 'zod'

type Param = z.infer<typeof actions['init']['paramsSchema']>

// TODO: Replace with actual params
const params: Param = {


  // TODO: token owner
  "owner": '$WALLET',


  // TODO: token name
  "name": 'TOKEN',


  // TODO: token symbol
  "symbol": 'TOKEN',


  // TODO: token max supply
  "maxSupply": BigInt(1000000),


  // TODO: token mint amount when deploy
  "initialSupply": BigInt(1000000)
}

// TODO: Replace with actual signer id
const signer = {
  "deployer": "$ACCOUNT_ID"
}

export default { params, signer, Action: DeployInfinitERC20Action }
EOF

echo
bunx infinit script execute deployInfinitErc20Action.script.ts


