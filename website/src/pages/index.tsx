import type {ReactNode} from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import Heading from '@theme/Heading';
import HomepageFeatures from '@site/src/components/HomepageFeatures';

import styles from './index.module.css';

const INSTALL_LINES: {t: 'comment' | 'cmd' | 'flag'; text: string}[] = [
  {t: 'comment', text: '# 1 — fork the repo, then clone your fork'},
  {t: 'cmd', text: 'git clone git@github.com:you/helm-gitlab.git'},
  {t: 'comment', text: '# 2 — tailor values + build your own images'},
  {t: 'cmd', text: 'helm dependency build .'},
  {t: 'comment', text: '# 3 — deploy your copy'},
  {t: 'cmd', text: 'helm upgrade --install gitlab . \\'},
  {t: 'flag', text: '  -n gitlab --create-namespace -f my-values.yaml'},
];

function Hero() {
  return (
    <header className={styles.hero}>
      <div className={styles.heroGrid} aria-hidden="true" />
      <div className={styles.heroGlow} aria-hidden="true" />
      <div className={clsx('container', styles.heroInner)}>
        <div className={styles.heroCopy}>
          <p className={styles.kicker}>
            <span className={styles.kickerDot} /> self-hosted gitlab on kubernetes
          </p>
          <Heading as="h1" className={styles.title}>
            Bring your own<br />
            <span className={styles.titleAccent}>datastores.</span>
          </Heading>
          <p className={styles.subtitle}>
            A GitLab Helm chart that wires the official GitLab subchart to
            first-class, in-cluster datastores — PostgreSQL HA, Valkey,
            SeaweedFS, and Traefik. There&apos;s nothing to install from a
            registry: <strong>fork it</strong>, tailor the values and images to
            your cluster, and deploy your own build.
          </p>
          <div className={styles.actions}>
            <Link className={styles.btnPrimary} to="/docs/intro">
              Read the docs <span aria-hidden="true">→</span>
            </Link>
            <Link
              className={styles.btnGhost}
              href="https://github.com/Bugs5382/helm-gitlab/fork">
              Fork it on GitHub
            </Link>
          </div>
        </div>

        <div className={styles.terminal} role="img" aria-label="helm install quick start">
          <div className={styles.termBar}>
            <span className={styles.termDot} data-c="r" />
            <span className={styles.termDot} data-c="y" />
            <span className={styles.termDot} data-c="g" />
            <span className={styles.termTitle}>fork → tailor → deploy</span>
          </div>
          <pre className={styles.termBody}>
            {INSTALL_LINES.map((l, i) => (
              <code key={i} className={styles[l.t]}>
                {l.text}
              </code>
            ))}
          </pre>
        </div>
      </div>
    </header>
  );
}

export default function Home(): ReactNode {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title={`${siteConfig.title} — bring-your-own-datastores GitLab on Kubernetes`}
      description={siteConfig.tagline}>
      <Hero />
      <main>
        <HomepageFeatures />
      </main>
    </Layout>
  );
}
