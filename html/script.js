window.addEventListener('message', (event) => {
    if (event.data.action === "updateBounties") {
        const container = document.getElementById('bounties');
        container.innerHTML = '';
        for (const id in event.data.bounties) {
            const bounty = event.data.bounties[id];
            const div = document.createElement('div');
            div.className = 'bounty-item';
            div.innerHTML = `
                <h3>Case #${bounty.id}</h3>
                <p>Reward: $${bounty.reward}</p>
                <button onclick="startBounty(${bounty.id})">Track Bounty</button>
            `;
            container.appendChild(div);
        }
    }
});

function closeUI() {
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({})
    });
}

function startBounty(id) {
    fetch(`https://${GetParentResourceName()}/startBounty`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ id: id })
    });
}
