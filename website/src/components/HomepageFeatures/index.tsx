import type {ReactNode} from 'react';
import Link from '@docusaurus/Link';
import Heading from '@theme/Heading';
import styles from './styles.module.css';

type StackItem = {
  glyph: string;
  title: string;
  tag: string;
  description: ReactNode;
};

const STACK: StackItem[] = [
  {
    glyph: '🐘',
    title: 'PostgreSQL 18',
    tag: 'primary + standby',
    description: 'Hand-rolled HA pair with async streaming replication and manual failover — no operator, no bundled single-pod DB.',
  },
  {
    glyph: '⚡',
    title: 'Valkey',
    tag: 'redis-compatible',
    description: 'A vendored Valkey chart for GitLab’s caching and queues, with auto-generated credentials kept stable across upgrades.',
  },
  {
    glyph: '🪣',
    title: 'SeaweedFS',
    tag: 'durable + cache',
    description: 'S3-compatible object storage — a durable instance for artifacts/LFS/registry, plus a disposable one for the runner cache.',
  },
  {
    glyph: '🚦',
    title: 'Traefik v3',
    tag: 'isolated class',
    description: 'Ingress on its own class so it never collides with a cluster-wide controller. Also carries Git SSH and toolbox SSH.',
  },
  {
    glyph: '🧩',
    title: 'Bring your own datastores',
    tag: 'in-cluster',
    description: 'You operate the backing services, in your cluster, under your control — production-grade, not evaluation defaults.',
  },
  {
    glyph: '📦',
    title: 'Source you deploy',
    tag: 'no prebuilt artifacts',
    description: 'No published image, no packaged chart. You build the images and run helm install ./ — the supply chain stays yours.',
  },
];

type DocLink = {to: string; label: string; blurb: string};

const DOCS: DocLink[] = [
  {to: '/docs/intro', label: 'Introduction', blurb: 'What it is and who it’s for.'},
  {to: '/docs/architecture', label: 'Architecture', blurb: 'Every component and how it fits.'},
  {to: '/docs/prerequisites', label: 'Prerequisites', blurb: 'What your cluster needs first.'},
  {to: '/docs/installation', label: 'Installation', blurb: 'Dependencies, values, and install.'},
  {to: '/docs/configuration', label: 'Configuration', blurb: 'Required values and tunables.'},
];

export default function HomepageFeatures(): ReactNode {
  return (
    <>
      <section className={styles.section}>
        <div className="container">
          <div className={styles.sectionHead}>
            <p className={styles.eyebrow}>the stack</p>
            <Heading as="h2" className={styles.sectionTitle}>
              Everything in-cluster, nothing hand-wavy
            </Heading>
          </div>
          <div className={styles.grid}>
            {STACK.map((s) => (
              <div key={s.title} className={styles.card}>
                <div className={styles.cardTop}>
                  <span className={styles.glyph}>{s.glyph}</span>
                  <span className={styles.tag}>{s.tag}</span>
                </div>
                <Heading as="h3" className={styles.cardTitle}>{s.title}</Heading>
                <p className={styles.cardDesc}>{s.description}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className={styles.docsSection}>
        <div className="container">
          <div className={styles.sectionHead}>
            <p className={styles.eyebrow}>documentation</p>
            <Heading as="h2" className={styles.sectionTitle}>
              Start here
            </Heading>
          </div>
          <div className={styles.docsGrid}>
            {DOCS.map((d) => (
              <Link key={d.to} to={d.to} className={styles.docCard}>
                <span className={styles.docLabel}>{d.label}</span>
                <span className={styles.docBlurb}>{d.blurb}</span>
                <span className={styles.docArrow} aria-hidden="true">→</span>
              </Link>
            ))}
          </div>
        </div>
      </section>
    </>
  );
}
