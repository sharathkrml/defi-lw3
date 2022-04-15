import Head from "next/head";
import styles from "../styles/Home.module.css";


export default function Home() {
  return (
    <div>
      <Head>
        <title>Crypto Devs</title>
        <meta name="description" content="Exchange-Dapp" />
        <link rel="icon" href="/favicon.ico" />
      </Head>
      <div className={styles.main}>
        <div>
          <h1 className={styles.title}>Welcome to Crypto Devs Exchange!</h1>
          <div className={styles.description}>
            Exchange Ethereum &#60;&#62; Crypto Dev Tokens
          </div>
          <div>
            <button
              className={styles.button}
              // onClick={() => {
              //   setLiquidityTab(!liquidityTab);
              // }}
            >
              Liquidity
            </button>
            <button
              className={styles.button}
              // onClick={() => {
              //   setLiquidityTab(false);
              // }}
            >
              Swap
            </button>
          </div>
          {/* {renderButton()} */}
        </div>
        <div>
          <img className={styles.image} src="./cryptodev.svg" />
        </div>
      </div>

      <footer className={styles.footer}>
        Made with &#10084; by Crypto Devs
      </footer>
    </div>
  );
}
