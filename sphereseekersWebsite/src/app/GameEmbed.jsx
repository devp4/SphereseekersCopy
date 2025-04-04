'use client';
import React, { useEffect, useState } from "react";
import {isMobile} from 'react-device-detect';

const GameEmbed = () => {
    const [isMounted, setIsMounted] = useState(false);

    useEffect(() => {
			const screen_orientation = screen.orientation.type
			screen.orientation.lock(screen_orientation)
      setIsMounted(true);
    }, []);

    if (!isMounted) {
        return <div>Loading...</div>;
    }

    if (isMobile) {
        return (
            <div className="game-container-mobile">
                <iframe
                    className="game-embed"
                    src="/game/index.html"
                    title="Sphereseeker"
                />
            </div>
        );
    }
    return (
        <div className="game-container">
            <iframe
                className="game-embed"
                src="/game/index.html"
                title="Sphereseeker"
            />
        </div>

    );
};

export default GameEmbed;