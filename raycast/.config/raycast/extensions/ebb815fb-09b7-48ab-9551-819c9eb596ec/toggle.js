"use strict";var r=Object.defineProperty;var w=Object.getOwnPropertyDescriptor;var p=Object.getOwnPropertyNames;var d=Object.prototype.hasOwnProperty;var m=(t,s)=>{for(var n in s)r(t,n,{get:s[n],enumerable:!0})},x=(t,s,n,o)=>{if(s&&typeof s=="object"||typeof s=="function")for(let i of p(s))!d.call(t,i)&&i!==n&&r(t,i,{get:()=>s[i],enumerable:!(o=w(s,i))||o.enumerable});return t};var N=t=>x(r({},"__esModule",{value:!0}),t);var y={};m(y,{default:()=>b});module.exports=N(y);var f=require("child_process"),a=require("@raycast/api"),e="DND Raycast";function c(t){return new Promise((s,n)=>{(0,f.exec)(t,(o,i,h)=>{o?n(o):s({stdout:i,stderr:h})})})}async function u(){let{stdout:t}=await c("shortcuts list");if(!t.split(`
`).map(o=>o.trim()).includes(e)){await(0,a.closeMainWindow)(),await(0,a.showHUD)("Installing Shortcut (this will only happen once)");let o=`${__dirname}/assets/${e}.shortcut`;return await(0,a.open)(o),!1}return!0}async function l(){let{stdout:t}=await c(`echo "status" | shortcuts run "${e}" | cat`);return t!==""}async function I(t){if(!await u())return;await c(`echo "on" | shortcuts run "${e}"`),await l()&&!t&&await(0,a.showHUD)("Do Not Disturb is on")}async function O(t){if(!await u())return;await c(`echo "off" | shortcuts run "${e}"`),!await l()&&!t&&await(0,a.showHUD)("Do Not Disturb is off")}async function D(t){if(!await u())return;await l()?await O(t):await I(t)}var b=async({launchContext:t={suppressHUD:!1}})=>{let{suppressHUD:s}=t;await D(s)};
