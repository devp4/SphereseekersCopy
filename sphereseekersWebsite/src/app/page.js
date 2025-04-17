'use client';
import GameEmbed from './GameEmbed';
import {isMobile} from 'react-device-detect';

export default function Page() {
  return (
    <div>
      <iframe
        src="/game/index.html"
        title="Sphereseeker"
        style={{width:'100%', height:'100vh', border:'none'}}
      />
    </div>
  )
}
