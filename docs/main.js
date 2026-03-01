const defaultTheme={bgMain:getComputedStyle(document.documentElement).getPropertyValue('--bg-main').trim(),bgGradientStart:getComputedStyle(document.documentElement).getPropertyValue('--bg-gradient-start').trim(),bgGradientEnd:getComputedStyle(document.documentElement).getPropertyValue('--bg-gradient-end').trim(),bgPanel:getComputedStyle(document.documentElement).getPropertyValue('--bg-panel').trim(),bgSidebar:getComputedStyle(document.documentElement).getPropertyValue('--bg-sidebar').trim(),bgHover:getComputedStyle(document.documentElement).getPropertyValue('--bg-hover').trim(),accent:getComputedStyle(document.documentElement).getPropertyValue('--accent').trim(),accentAlt:getComputedStyle(document.documentElement).getPropertyValue('--accent-alt').trim(),textMain:getComputedStyle(document.documentElement).getPropertyValue('--text-main').trim(),textMuted:getComputedStyle(document.documentElement).getPropertyValue('--text-muted').trim(),textSubtle:getComputedStyle(document.documentElement).getPropertyValue('--text-subtle').trim(),borderSoft:getComputedStyle(document.documentElement).getPropertyValue('--border-soft').trim(), dockBlock:getComputedStyle(document.documentElement).getPropertyValue('--dock-block').trim()};
const darkTheme={bgMain:'#111111',bgGradientStart:'#0F0F0F',bgGradientEnd:'#1C1C1C',bgPanel:'#1A1A1A',bgSidebar:'#1E1E1E',bgHover:'#2A2A2A',accent:'#9B5DE5',accentAlt:'#F15BB5',textMain:'#EEE',textMuted:'#CCC',textSubtle:'#BBB',borderSoft:'#333', dockBlock:'#1a1919'};
const lightTheme={bgMain:'#FFFFFF',bgGradientStart:'#F0F0F0',bgGradientEnd:'#E0E0E0',bgPanel:'#FFFFFF',bgSidebar:'#F8F8F8',bgHover:'#E5E5E5',accent:'#5D5DE5',accentAlt:'#F1BB55',textMain:'#111111',textMuted:'#333333',textSubtle:'#555555',borderSoft:'#DDD', dockBlock:'#b4b1b1'};
function applyTheme(theme){for(const [k,v] of Object.entries(theme)){document.documentElement.style.setProperty('--'+k.replace(/[A-Z]/g,m=>'-'+m.toLowerCase()),v);}}
const themes=['default','dark','light'];
const icons=['📚','🌙','☀️'];
let themeState=0;
const themeContainer=document.createElement('div');
themeContainer.style.position='fixed';
themeContainer.style.top='10px';
themeContainer.style.right='10px';
themeContainer.style.left='auto';
themeContainer.style.display='flex';
themeContainer.style.flexDirection='column';
themeContainer.style.gap='10px';
themeContainer.style.zIndex='9999';
const themeButtons=themes.map((t,i)=>{const btn=document.createElement('button');btn.className='theme-btn';btn.innerText=icons[i];btn.style.background=i===themeState?'var(--accent)':'var(--bg-panel)';btn.style.color=i===themeState?'#fff':'var(--text-muted)';btn.addEventListener('click',()=>{themeState=i;applySelectedTheme();});themeContainer.appendChild(btn);return btn;});
document.body.appendChild(themeContainer);
function applySelectedTheme(){themeButtons.forEach((b,i)=>{b.style.background=i===themeState?'var(--accent)':'var(--bg-panel)';b.style.color=i===themeState?'#fff':'var(--text-muted)';});if(themeState===0)applyTheme(defaultTheme);else if(themeState===1)applyTheme(darkTheme);else applyTheme(lightTheme);}
function buildMenu(obj,parentPath='',isSubmenu=true,depth=0){const ul=document.createElement('ul');if(isSubmenu){ul.classList.add('submenu');ul.style.setProperty('--depth',depth);}for(const [k,v] of Object.entries(obj)){const li=document.createElement('li');if(v&&typeof v==='object'){const btn=document.createElement('button');btn.className='dropdown-toggle';btn.textContent=`${k} ▾`;btn.style.paddingLeft=`${depth*1.25}em`;li.appendChild(btn);const subMenu=buildMenu(v,parentPath+k+'/',true,depth+1);li.appendChild(subMenu);btn.addEventListener('click',()=>{subMenu.classList.toggle('visible');btn.classList.toggle('active');});}else{const a=document.createElement('a');a.style.paddingLeft=`${depth*1.25}em`;if(k.endsWith('.html')){a.href='/Nexum/pages/'+parentPath+k;a.textContent=k.replace(/\.html$/,'');}else{a.href=`/index.html#${(parentPath+k).replace(/[./]/g,'_')}`;a.textContent=k;}li.appendChild(a);}ul.appendChild(li);}return ul;}
function buildSidebarMenu(manifest){if(!manifest){document.querySelector('.content').innerHTML=`<h1>Erreur</h1><p>Manifest introuvable ou invalide.</p>`;return;}const menuRoot=document.getElementById('sidebar-menu');menuRoot.innerHTML=`<li><a href="/Nexum/index.html#intro">Introduction</a></li>`;menuRoot.appendChild(buildMenu(manifest,'',false,0));menuRoot.innerHTML+=`<li><a href="/Nexum/index.html#license">License</a></li>`;
document.querySelectorAll('.dropdown-toggle').forEach(btn=>{btn.addEventListener('click',e=>{e.preventDefault();const submenu=btn.nextElementSibling;submenu.classList.toggle('visible');btn.classList.toggle('active');});});
document.querySelectorAll('.copy-btn').forEach(btn=>{btn.addEventListener('click',()=>{const code=btn.nextElementSibling.innerText;navigator.clipboard.writeText(code).then(()=>{btn.classList.add('copied');btn.innerText='✅';setTimeout(()=>{btn.classList.remove('copied');btn.innerText='📋';},1500);});});});
/* ================= SEARCH SIDEBAR ================= */
const searchInput=document.getElementById('sidebarSearch');
if(searchInput){searchInput.addEventListener('keyup',()=>{const filter=searchInput.value.toLowerCase();document.querySelectorAll('.sidebar li').forEach(li=>{const link=li.querySelector('a');if(!link)return;const txt=link.textContent.toLowerCase();const match=txt.includes(filter);li.style.display=match?'':'none';if(match){let parent=li.parentElement.closest('li');while(parent){const btn=parent.querySelector('.dropdown-toggle');if(btn){btn.classList.add('active');btn.nextElementSibling.classList.add('visible');}parent=parent.parentElement.closest('li');}}});});}
/* ================= ACTIVE SELECTION ================= */
const currentPath=window.location.pathname.split('/').pop()||'index.html';
const currentHash=window.location.hash.slice(1);
document.querySelectorAll('.sidebar a').forEach(link=>{
	const linkHref = link.getAttribute('href');
	const linkPath = linkHref.split('#')[0].split('/').pop();
	const linkHash = linkHref.split('#')[1] || '';
	
	// Sélection visuelle
	if(linkPath === currentPath && (linkHash === currentHash || (currentHash === '' && linkHash === ''))) {
		link.classList.add('active');
		let parent = link.parentElement;
		while(parent && parent.tagName==='LI') {
			const btn = parent.querySelector('.dropdown-toggle');
			if(btn){btn.classList.add('active');btn.nextElementSibling.classList.add('visible');}
			parent = parent.parentElement.closest('li');
		}
	}
	
	// Gestion clic sur #intro/#license → reload pour appliquer sélection
	if((linkHash === 'intro' || linkHash === 'license') && currentPath === 'index.html') {
		link.addEventListener('click', e=>{
			if(linkHash !== currentHash){
				window.location.href = link.href;
				window.location.reload(true);
			}
			e.preventDefault();
		});
	}
	
	// Ne reload pas si clic sur la page courante
	if(linkPath === currentPath && linkHash === '') {
		link.addEventListener('click', e=> e.preventDefault());
	}
});
}
document.addEventListener('DOMContentLoaded',()=>{buildSidebarMenu(manifest)});
