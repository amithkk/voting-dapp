import { parseBytes32String } from "@ethersproject/strings";
import { useWeb3React } from "@web3-react/core";
import Head from "next/head";
import Link from "next/link";
import Account from "../components/Account";
import ETHBalance from "../components/ETHBalance";
import { DAppHeader } from "../components/DAppHeader";
import TokenBalance from "../components/TokenBalance";
import useEagerConnect from "../hooks/useEagerConnect";
import useVotingContract from "../hooks/useVotingContract";
import useVotingDapp from "../hooks/useVotingDapp";
import Stats from "../components/Stats";
import { Container, Stack } from "@mantine/core";
import { formatEther } from "@ethersproject/units";
import BuyTokens from "../components/BuyTokens";
import CandidateVotes from "../components/CandidateVotes";
import { NotConnected } from "../components/NotConnected";

const VOTING_TOKEN_ADDRESS = "0xD52072e44362245F7b13873b061932267D3819a6";

function Home() {
  const { account, library } = useWeb3React();

  const [
    contractState,
    contractBalance,
    buyTokens,
    voteForCandidate,
    withdrawTokens,
  ] = useVotingDapp(VOTING_TOKEN_ADDRESS);

  const triedToEagerConnect = useEagerConnect();

  const isConnected = typeof account === "string" && !!library;

  return (
    <>
      <Head>
        <title>ClubVoting DApp</title>
      </Head>
      <DAppHeader triedToEagerConnect={triedToEagerConnect}></DAppHeader>
      {isConnected ? (
        <Container mb="40px">
          <Stack>
            <BuyTokens onBuy={buyTokens}></BuyTokens>
            <Stats
              contractState={contractState}
              contractBalance={
                contractBalance.data ? formatEther(contractBalance.data) : "0"
              }
              withdrawTokens={() => {
                withdrawTokens(account);
              }}
            ></Stats>
            <CandidateVotes
              contractState={contractState}
              onVote={voteForCandidate}
            ></CandidateVotes>
          </Stack>
        </Container>
      ) : (
        <NotConnected></NotConnected>
      )}
    </>
  );
}

export default Home;
