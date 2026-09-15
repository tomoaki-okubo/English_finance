import '../../domain/entities/chat_reply_option.dart';

class RoleplayScenario {
  final String id;
  final String personaId;
  final String title;
  final String description;
  final String initialAiGreeting;
  final List<ChatReplyOption> initialOptions;

  const RoleplayScenario({
    required this.id,
    required this.personaId,
    required this.title,
    required this.description,
    required this.initialAiGreeting,
    required this.initialOptions,
  });
}

class RoleplayScenariosData {
  static RoleplayScenario getInitialScenarioFor(String personaId) {
    return scenarios.firstWhere(
      (s) => s.personaId == personaId,
      orElse: () => scenarios.first,
    );
  }

  static const List<RoleplayScenario> scenarios = [
    // ==========================================
    // James (Investment Banker) Scenarios
    // ==========================================
    RoleplayScenario(
      id: 'banker_ma_deal',
      personaId: 'banker',
      title: 'M&A Deal Structuring',
      description: 'Discussing the acquisition structure and financing terms for a cross-border M&A deal with James.',
      initialAiGreeting:
          "Hi! I've been working on the financial model for the cross-border acquisition of TechCorp. The target's enterprise value is around \$2.5 billion. Do you have any thoughts on the deal structure?",
      initialOptions: [
        ChatReplyOption(
          text: "Thanks for the update. What's the proposed debt-to-equity ratio for the acquisition financing? We need to ensure the leverage is manageable.",
          label: "💡 Recommended",
          translationJa: "報告ありがとうございます。買収ファイナンスの負債資本比率はどの程度ですか？レバレッジが管理可能であることを確認する必要があります。",
          aiReplies: [
            "We're targeting a 60/40 debt-to-equity split. The senior secured debt facility would be \$1.5 billion with a 5-year term.",
            "Good question! I'm modeling a 65/35 leverage ratio. The interest coverage ratio looks comfortable at 3.5x even under stress scenarios.",
            "We've structured it as 55/45 debt-to-equity. The syndicated loan commitment from three lead banks is already at term sheet stage.",
          ],
          nextOptions: [
            ChatReplyOption(
              text: "That seems reasonable. Have we also considered the impact on the combined entity's credit rating post-acquisition?",
              label: "💡 Constructive",
              translationJa: "妥当ですね。買収後の統合企業の信用格付けへの影響も検討しましたか？",
              aiReplies: [
                "Yes, Moody's pre-sounded us and indicated the combined entity could maintain investment-grade if we stay below 3.0x net leverage.",
                "Great point! I've factored in the rating agency methodology. We should be safe at BBB if synergies materialize as projected.",
                "Absolutely. Our credit advisory team estimates a one-notch downgrade initially, but the rating should recover within 18 months as we deleverage.",
              ],
              nextOptions: [
                ChatReplyOption(
                  text: "Excellent. Let's finalize the term sheet and schedule the investment committee presentation for next week.",
                  label: "💡 Wrap-up",
                  translationJa: "素晴らしいです。タームシートを最終化し、来週の投資委員会プレゼンテーションのスケジュールを組みましょう。",
                  aiReplies: [
                    "I'll have the term sheet and IC memo ready by Thursday. Let me know if you need any additional analysis.",
                    "Sounds good! I'll coordinate with the legal team on the documentation and prepare the presentation deck.",
                    "Perfect. I'll also prepare a sensitivity analysis showing the impact of different synergy assumptions on returns.",
                  ],
                ),
              ],
            ),
            ChatReplyOption(
              text: "Could you also model an earnout structure to bridge the valuation gap with the seller?",
              label: "💡 Deal Structuring",
              translationJa: "売り手との評価額ギャップを埋めるために、アーンアウト構造のモデルも作成していただけますか？",
              aiReplies: [
                "Sure! I'll model a \$300 million earnout tied to EBITDA targets over 2 years. That should help close the gap.",
                "Good idea. An earnout would align incentives with the seller. I'll draft scenarios with different performance hurdles.",
                "Already on it! I'm modeling a 20% earnout component contingent on revenue milestones. It also protects our downside.",
              ],
              nextOptions: [
                ChatReplyOption(
                  text: "Great approach. Let's discuss the earnout metrics with the seller's advisor during due diligence.",
                  label: "💡 Wrap-up",
                  translationJa: "良いアプローチですね。デューデリジェンス中に売り手のアドバイザーとアーンアウトの指標について協議しましょう。",
                  aiReplies: [
                    "Agreed. I'll prepare the earnout term sheet proposals before the meeting with their advisory team.",
                    "Will do! I'll also benchmark earnout structures from comparable M&A transactions in the sector.",
                    "Sounds good. I'll coordinate with our legal team on the earnout agreement clauses as well.",
                  ],
                ),
              ],
            ),
          ],
        ),
        ChatReplyOption(
          text: "Can you also handle the regulatory filings and antitrust clearance yourself?",
          label: "⚠️ Banker Trigger",
          translationJa: "規制当局への届出と独占禁止法の承認手続きもJamesの方で対応してもらえますか？",
          aiReplies: [
            "Regulatory filings and antitrust clearance are handled by our legal and compliance teams. I focus on deal structuring and financial analysis.",
            "That's outside my scope as an investment banker. Our legal counsel and the compliance department handle regulatory approvals.",
            "I wouldn't be the right person for that. Regulatory filings require specialized legal expertise. Let me connect you with our legal team.",
          ],
          nextOptions: [
            ChatReplyOption(
              text: "You're right, I apologize. I'll coordinate with the legal team for regulatory filings separately.",
              label: "💡 Acknowledge",
              translationJa: "おっしゃる通りです、すみません。規制当局への届出については法務チームと別途調整します。",
              aiReplies: [
                "No problem! I'll make sure our financial analysis supports whatever regulatory narrative the legal team needs.",
                "Thanks for understanding. I'll provide the financial data the legal team needs for the competition law filings.",
                "Happy to help coordinate. Let me introduce you to our head of legal who handles cross-border regulatory matters.",
              ],
              nextOptions: [
                ChatReplyOption(
                  text: "Thanks, James. Let's focus on completing the financial model and preparing the pitch book.",
                  label: "💡 Wrap-up",
                  translationJa: "ありがとう、James。財務モデルの完成とピッチブックの準備に集中しましょう。",
                  aiReplies: [
                    "Absolutely! I'll have the pitch book ready for your review by end of week.",
                    "On it! The financial model is almost done. I'll send you the draft for feedback tomorrow.",
                    "Sounds good. I'll finalize the comparable transactions analysis and include it in the pitch materials.",
                  ],
                ),
              ],
            ),
          ],
        ),
        ChatReplyOption(
          text: "The valuation looks high. Let's just offer 30% below the asking price and see if they accept.",
          label: "❌ Risky",
          translationJa: "評価額が高すぎますね。提示価格より30%低いオファーを出して反応を見ましょう。",
          aiReplies: [
            "A 30% discount without justification could offend the seller and kill the deal entirely. We need a data-driven approach to negotiate.",
            "That's too aggressive. A lowball offer without supporting analysis damages our credibility. Let's use comparable valuations to justify our position.",
            "I strongly advise against that. In M&A, a reasonable opening offer backed by solid analysis is far more effective than an aggressive lowball.",
          ],
          nextOptions: [
            ChatReplyOption(
              text: "Fair point. Let's build a robust valuation model using DCF and comparable transactions to support a reasonable offer.",
              label: "💡 Corrected",
              translationJa: "ごもっともです。妥当なオファーを裏付けるために、DCFと類似取引を用いた堅実な評価モデルを構築しましょう。",
              aiReplies: [
                "That's the right approach! I'll prepare a DCF and trading comps analysis to establish a defensible valuation range.",
                "Much better. I'll run a football field analysis combining DCF, comps, and precedent transactions.",
                "Agreed. A well-supported valuation range gives us much stronger negotiating leverage with the seller.",
              ],
              nextOptions: [
                ChatReplyOption(
                  text: "Great. Let's present a fair range to the seller and work toward a mutually beneficial deal.",
                  label: "💡 Wrap-up",
                  translationJa: "素晴らしいですね。売り手に妥当なレンジを提示し、双方にとって有益な取引を目指しましょう。",
                  aiReplies: [
                    "I'll have the complete valuation analysis ready for review by tomorrow afternoon.",
                    "Perfect. A fair deal is always better than no deal. I'll prepare the presentation for the negotiation session.",
                    "Agreed! I'll make sure we have a compelling narrative that justifies our valuation to the seller's board.",
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    RoleplayScenario(
      id: 'banker_ipo_pricing',
      personaId: 'banker',
      title: 'IPO Pricing & Book Building',
      description: 'Discussing IPO pricing strategy and investor demand during the book-building process with James.',
      initialAiGreeting:
          "The roadshow for GreenTech Energy's IPO just wrapped up. We've received strong investor interest. The indicative price range is \$18-22 per share. How should we approach the final pricing?",
      initialOptions: [
        ChatReplyOption(
          text: "What does the order book look like? Is the offering oversubscribed, and what's the quality of demand from institutional investors?",
          label: "💡 Recommended",
          translationJa: "注文状況はどうですか？オファリングは超過需要ですか？機関投資家からの需要の質はどうですか？",
          aiReplies: [
            "The book is 8x oversubscribed with strong demand from tier-1 institutional investors. About 70% of orders are from long-only funds.",
            "Excellent demand! We're 6x oversubscribed. The top 20 accounts include major pension funds and sovereign wealth funds.",
            "Very strong book. We're 10x oversubscribed with high-quality anchor orders from BlackRock, Vanguard, and several sovereign wealth funds.",
          ],
          nextOptions: [
            ChatReplyOption(
              text: "With such strong demand, I think we should price at the top of the range at \$22 to maximize proceeds for the issuer.",
              label: "💡 Constructive",
              translationJa: "そこまで強い需要であれば、発行体の調達額を最大化するため、レンジ上限の22ドルで値付けすべきだと思います。",
              aiReplies: [
                "I agree, but let's also consider a modest first-day pop of 10-15% to reward investors. Pricing at \$21 might be the sweet spot.",
                "Top of range is justified. However, we should leave some upside for investors to build goodwill for future offerings.",
                "Good thinking! I'd recommend \$21.50 — close to the top but leaving enough upside for a healthy first-day performance.",
              ],
              nextOptions: [
                ChatReplyOption(
                  text: "That makes sense. Let's recommend \$21.50 to the issuer and finalize the allocation strategy.",
                  label: "💡 Wrap-up",
                  translationJa: "理にかなっていますね。発行体に21.50ドルを提案し、配分戦略を最終化しましょう。",
                  aiReplies: [
                    "I'll prepare the pricing memo and allocation recommendation for the pricing committee tonight.",
                    "Agreed! I'll also draft the allocation schedule prioritizing long-term institutional holders.",
                    "Perfect. I'll coordinate with the syndicate desk to finalize allocation and prepare the pricing announcement.",
                  ],
                ),
              ],
            ),
          ],
        ),
        ChatReplyOption(
          text: "Let's price way above the range at \$30 to get maximum value for our client.",
          label: "❌ Risky",
          translationJa: "クライアントの最大価値のために、レンジを大幅に超えて30ドルで値付けしましょう。",
          aiReplies: [
            "Pricing 36% above the range would severely damage investor trust and likely cause the stock to collapse on day one.",
            "That would be extremely reckless. Overpricing an IPO destroys the company's market credibility and our reputation as underwriters.",
            "I cannot recommend that. An overpriced IPO leads to poor aftermarket performance and damages relationships with investors for future deals.",
          ],
          nextOptions: [
            ChatReplyOption(
              text: "You're right. Let's price within the range based on demand quality and leave room for healthy aftermarket trading.",
              label: "💡 Corrected",
              translationJa: "おっしゃる通りです。需要の質に基づいてレンジ内で値付けし、健全なアフターマーケット取引の余地を残しましょう。",
              aiReplies: [
                "That's the professional approach. I'll prepare the pricing analysis based on institutional demand and comparable IPO performance.",
                "Agreed. Balanced pricing protects both the issuer's interests and our relationship with the investor base.",
                "Much better. Let me finalize the analysis and present our recommended price to the pricing committee.",
              ],
            ),
          ],
        ),
      ],
    ),

    // ==========================================
    // Sarah (Risk Analyst) Scenarios
    // ==========================================
    RoleplayScenario(
      id: 'risk_credit_review',
      personaId: 'risk',
      title: 'Credit Portfolio Risk Review',
      description: 'Reviewing the credit risk exposure and concentration limits in the lending portfolio with Sarah.',
      initialAiGreeting:
          "Good morning! I've completed the quarterly credit risk review. Our commercial real estate loan portfolio concentration has exceeded the 25% sector limit, reaching 28.3%. We need to discuss remediation steps.",
      initialOptions: [
        ChatReplyOption(
          text: "Thank you for flagging this. What's driving the concentration increase — is it new originations or changes in the total portfolio size?",
          label: "💡 Recommended",
          translationJa: "指摘ありがとうございます。集中度の増加は新規融資実行によるものですか、それとも総ポートフォリオ規模の変化ですか？",
          aiReplies: [
            "It's a combination. We had \$200 million in new CRE originations last quarter, and the total portfolio shrank 3% due to scheduled repayments in other sectors.",
            "Good question! The main driver is \$180 million in new CRE loans approved before the limit breach was detected in the monthly monitoring.",
            "It's primarily new originations. The lending team approved several large CRE facilities without checking against the concentration dashboard.",
          ],
          nextOptions: [
            ChatReplyOption(
              text: "I see. Should we pause new CRE originations until we're back within limits, or can we use risk transfer mechanisms like loan sales or syndication?",
              label: "💡 Proactive",
              translationJa: "なるほど。制限内に戻るまで新規CRE融資を停止すべきですか、それともローン売却やシンジケーションなどのリスク移転手法が使えますか？",
              aiReplies: [
                "I recommend a temporary origination freeze plus syndication of \$150 million in existing CRE exposure. That would bring us to 24.5%.",
                "We should implement both. Pause new approvals and sell down \$100 million via our secondary loan trading desk to get below 25% fast.",
                "Good options. I'd suggest a combination: freeze new CRE lending for 60 days while we arrange a \$120 million risk participation with partner banks.",
              ],
              nextOptions: [
                ChatReplyOption(
                  text: "Good plan. Let's present the remediation strategy to the Risk Committee this Friday.",
                  label: "💡 Wrap-up",
                  translationJa: "良い計画です。今週金曜日のリスク委員会に是正戦略を提示しましょう。",
                  aiReplies: [
                    "I'll prepare the Risk Committee presentation with the concentration analysis, proposed limits, and timeline for remediation.",
                    "Will do. I'll also include a stress test showing the CRE portfolio's performance under a 30% property value decline scenario.",
                    "I'll have everything ready. Should I also include a comparison with peer banks' CRE exposure levels?",
                  ],
                ),
              ],
            ),
          ],
        ),
        ChatReplyOption(
          text: "Can you just adjust the concentration limit from 25% to 30% so we don't have a breach?",
          label: "❌ Risky",
          translationJa: "違反にならないように集中度制限を25%から30%に引き上げることはできますか？",
          aiReplies: [
            "Simply raising the limit to avoid a breach defeats the purpose of risk management. The limits exist to protect the bank from concentration risk.",
            "That's exactly what we shouldn't do. Changing risk limits to fit current exposures rather than managing the exposure is a major governance red flag.",
            "I must strongly advise against that. Regulators would view arbitrary limit increases as weak risk governance. We need to reduce exposure, not relax controls.",
          ],
          nextOptions: [
            ChatReplyOption(
              text: "You're absolutely right. Let's focus on reducing the actual exposure instead of changing our risk framework.",
              label: "💡 Corrected",
              translationJa: "おっしゃる通りです。リスクフレームワークを変更するのではなく、実際のエクスポージャーを削減することに集中しましょう。",
              aiReplies: [
                "Thank you for understanding! I'll prepare actionable options for exposure reduction and present them to the Risk Committee.",
                "Exactly right. I'll model several remediation paths and recommend the most cost-effective approach.",
                "Glad you agree. Maintaining the integrity of our risk limits is critical for regulatory confidence and shareholder trust.",
              ],
            ),
          ],
        ),
      ],
    ),

    RoleplayScenario(
      id: 'risk_stress_test',
      personaId: 'risk',
      title: 'Regulatory Stress Test Preparation',
      description: 'Preparing the bank\'s annual regulatory stress test submission with Sarah.',
      initialAiGreeting:
          "The regulator just released the stress test scenarios for this year. The severely adverse scenario includes a 40% equity market decline, 300bp interest rate shock, and unemployment rising to 12%. Our CET1 ratio projection needs to stay above 4.5%. Should we start the modeling?",
      initialOptions: [
        ChatReplyOption(
          text: "Yes, let's start immediately. Which portfolios are you most concerned about under the severely adverse scenario?",
          label: "💡 Recommended",
          translationJa: "はい、すぐに開始しましょう。深刻な悪化シナリオの下で最も懸念しているポートフォリオはどれですか？",
          aiReplies: [
            "I'm most worried about our leveraged lending book and the CRE portfolio. Both are highly sensitive to economic downturns and rate shocks.",
            "The consumer credit card portfolio concerns me most. With unemployment at 12%, we'd see significant charge-off increases. Also, the CRE book.",
            "Two areas: our fixed-rate bond portfolio, which would suffer mark-to-market losses from the rate shock, and the commercial lending book.",
          ],
          nextOptions: [
            ChatReplyOption(
              text: "Let's run the models on those portfolios first. Can you also check if our capital conservation buffer remains adequate under stress?",
              label: "💡 Constructive",
              translationJa: "それらのポートフォリオのモデルを最初に実行しましょう。ストレス下で資本保全バッファーも十分か確認してもらえますか？",
              aiReplies: [
                "Absolutely. I'll model the capital trajectory quarter by quarter through the 9-quarter stress horizon and check buffer adequacy.",
                "On it. I'll also run a reverse stress test to find the breaking point where CET1 drops below the 4.5% minimum.",
                "Will do. I'll prepare the full capital adequacy projection including the impact on RWA inflation under the adverse scenario.",
              ],
              nextOptions: [
                ChatReplyOption(
                  text: "Excellent. Let's have preliminary results by next Wednesday so we have time to review before the submission deadline.",
                  label: "💡 Wrap-up",
                  translationJa: "素晴らしいです。提出期限前に確認の時間を確保するため、来週水曜日までに暫定結果を出しましょう。",
                  aiReplies: [
                    "I'll have the preliminary stress test results ready by Wednesday. I'll also flag any areas where we might need management overlays.",
                    "Agreed. I'll coordinate with the finance team on the pre-provision net revenue projections to complete the model.",
                    "Consider it done. I'll schedule a working session with the modeling team to accelerate the timeline.",
                  ],
                ),
              ],
            ),
          ],
        ),
        ChatReplyOption(
          text: "Can you use last year's stress test model without updating the data? It will save us a lot of time.",
          label: "❌ Risky",
          translationJa: "データを更新せずに昨年のストレステストモデルをそのまま使えますか？時間の大幅な節約になります。",
          aiReplies: [
            "Using stale data would produce inaccurate results and violate the regulator's model governance requirements. We must use current portfolio data.",
            "That's a major regulatory risk. The regulator expects models to reflect current portfolio composition and macroeconomic conditions.",
            "I can't recommend that. If the regulator discovers we used outdated data, the bank faces enforcement action and reputational damage.",
          ],
          nextOptions: [
            ChatReplyOption(
              text: "You're right, accuracy is critical. Let's use the latest data and update the models properly.",
              label: "💡 Corrected",
              translationJa: "おっしゃる通りです、正確性が重要です。最新のデータを使用し、モデルを適切に更新しましょう。",
              aiReplies: [
                "Thank you. I'll coordinate with the data team to get the latest portfolio snapshots loaded into the stress test models.",
                "Exactly. I'll also make sure we document all model updates for the audit trail. The regulator reviews our methodology carefully.",
                "Glad you agree. I'll set up a project plan to ensure we update everything properly while still meeting the deadline.",
              ],
            ),
          ],
        ),
      ],
    ),

    // ==========================================
    // David (Fund Manager) Scenarios
    // ==========================================
    RoleplayScenario(
      id: 'fund_portfolio_review',
      personaId: 'fund',
      title: 'Quarterly Portfolio Review',
      description: 'Reviewing fund performance, attribution analysis, and rebalancing strategy with David.',
      initialAiGreeting:
          "Good afternoon! The quarterly portfolio review is ready. Our Global Growth Fund returned 8.2% this quarter, outperforming the MSCI World benchmark by 150 basis points. The key driver was our overweight position in AI semiconductor stocks. Want to walk through the attribution?",
      initialOptions: [
        ChatReplyOption(
          text: "Great performance! Yes, let's review the attribution. Which sectors contributed most, and are there any positions we should consider trimming?",
          label: "💡 Recommended",
          translationJa: "素晴らしい運用成績ですね！はい、アトリビューションを確認しましょう。最も貢献したセクターはどれで、ポジションの縮小を検討すべき銘柄はありますか？",
          aiReplies: [
            "Technology added 400bp of alpha from our NVIDIA and TSMC positions. Healthcare added 80bp. I'd recommend trimming NVIDIA as it's now 8% of the portfolio, exceeding our single-stock limit.",
            "The AI theme drove most of the outperformance. Our top contributors were semiconductor stocks. However, I'm concerned about concentration — tech is now 42% of AUM.",
            "Sector allocation added 200bp and stock selection added 130bp. Our biggest winners were in tech and healthcare. I think we should take some profits on the AI names.",
          ],
          nextOptions: [
            ChatReplyOption(
              text: "Agreed on trimming. What's your recommendation for redeploying the proceeds? Should we increase our defensive allocation?",
              label: "💡 Constructive",
              translationJa: "縮小に賛成です。売却代金の再投資先としての推奨は？ディフェンシブ銘柄への配分を増やすべきですか？",
              aiReplies: [
                "I'd suggest rotating into healthcare and consumer staples. Also, our fixed income allocation is underweight — adding investment-grade bonds would reduce portfolio volatility.",
                "Given the economic outlook, I recommend increasing our allocation to quality dividend stocks and adding a 5% position in gold as a hedge.",
                "I'd recommend a barbell approach: trim growth stocks, add to value names in financials and industrials, and increase our cash buffer to 5% for opportunities.",
              ],
              nextOptions: [
                ChatReplyOption(
                  text: "Good strategy. Let's execute the rebalancing trades over the next two weeks to minimize market impact.",
                  label: "💡 Wrap-up",
                  translationJa: "良い戦略ですね。市場への影響を最小化するために、2週間かけてリバランス取引を実行しましょう。",
                  aiReplies: [
                    "I'll work with the trading desk to execute the trades gradually using VWAP orders to minimize slippage.",
                    "Agreed. I'll prepare the trade list and coordinate with our execution team for optimal timing.",
                    "Perfect. I'll also update the investment committee on the rationale for the rebalancing at next week's meeting.",
                  ],
                ),
              ],
            ),
          ],
        ),
        ChatReplyOption(
          text: "8.2% is good but not great. Can we take on much more risk to push for 15% returns next quarter?",
          label: "❌ Risky",
          translationJa: "8.2%は良いですがもっと上を目指したいです。来四半期に15%のリターンを狙って大幅にリスクを取りましょう。",
          aiReplies: [
            "Pushing for 15% would require excessive concentration and leverage that violates our fund mandate. Our risk-adjusted return is already top quartile among peers.",
            "Our investors chose this fund for consistent risk-adjusted returns, not for speculation. Chasing 15% would breach our investment policy and fiduciary duty.",
            "That would mean taking on disproportionate risk. Our Sharpe ratio is excellent at 1.8. Chasing higher returns often leads to larger drawdowns.",
          ],
          nextOptions: [
            ChatReplyOption(
              text: "You're right. Consistent, risk-adjusted outperformance is more important than short-term aggressive returns. Let's stay disciplined.",
              label: "💡 Corrected",
              translationJa: "おっしゃる通りです。短期的な攻めのリターンより、一貫したリスク調整後のアウトパフォーマンスの方が重要です。規律を維持しましょう。",
              aiReplies: [
                "Exactly! Our investors trust us for disciplined risk management. Let me present the optimal rebalancing strategy at the IC meeting.",
                "That's the right mindset. Our track record of consistent outperformance is what attracts institutional capital.",
                "Agreed. I'll focus on finding alpha opportunities within our risk budget rather than expanding the risk envelope.",
              ],
            ),
          ],
        ),
      ],
    ),

    RoleplayScenario(
      id: 'fund_esg_mandate',
      personaId: 'fund',
      title: 'ESG Integration & Screening',
      description: 'Discussing ESG screening criteria and their impact on portfolio construction with David.',
      initialAiGreeting:
          "We've received a new mandate from a European pension fund that requires full ESG integration. They want us to exclude fossil fuels, controversial weapons, and companies with poor governance scores. This will affect about 12% of our current investment universe. How should we approach the portfolio construction?",
      initialOptions: [
        ChatReplyOption(
          text: "Understood. Can you quantify the expected tracking error impact of these exclusions against our standard benchmark?",
          label: "💡 Recommended",
          translationJa: "了解しました。これらの除外が標準ベンチマークに対するトラッキングエラーにどの程度影響するか定量化できますか？",
          aiReplies: [
            "Based on my analysis, the exclusions would increase tracking error by approximately 80 basis points. However, substituting with clean energy stocks can reduce it to 50bp.",
            "Good question. The estimated tracking error increase is 60-90bp. I've identified sector substitutes that can maintain similar factor exposures.",
            "I've modeled it. The exclusions add about 70bp of tracking error, but historically, ESG-screened portfolios have actually outperformed over 5-year periods.",
          ],
          nextOptions: [
            ChatReplyOption(
              text: "That's manageable. Let's use a best-in-class approach within each sector to minimize the tracking error while meeting ESG requirements.",
              label: "💡 Constructive",
              translationJa: "管理可能な範囲ですね。ESG要件を満たしつつトラッキングエラーを最小化するために、各セクター内でベスト・イン・クラスのアプローチを使いましょう。",
              aiReplies: [
                "Great approach! I'll construct the portfolio using sector-neutral best-in-class ESG scoring. This keeps sector allocation aligned with the benchmark.",
                "Exactly what I'd recommend. I'll also integrate our proprietary ESG scoring model to identify companies with improving sustainability trajectories.",
                "Perfect. I'll build the portfolio with the ESG overlay and prepare a detailed report showing the client how their constraints affect expected returns.",
              ],
              nextOptions: [
                ChatReplyOption(
                  text: "Excellent. Please prepare the proposal for the pension fund by next Friday. Include the backtested performance comparison.",
                  label: "💡 Wrap-up",
                  translationJa: "素晴らしい。来週金曜日までに年金基金への提案書を準備してください。バックテストした運用実績比較も含めてください。",
                  aiReplies: [
                    "Will do! I'll include a 10-year backtest comparing ESG-screened versus unscreened performance to demonstrate the minimal return impact.",
                    "I'll have it ready. I'll also include our engagement strategy for companies on the ESG watchlist — the client will want to see our stewardship approach.",
                    "Consider it done. I'll also prepare the ESG reporting framework so the client can see quarterly ESG metrics alongside financial performance.",
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    // ==========================================
    // Lisa (Compliance Officer) Scenarios
    // ==========================================
    RoleplayScenario(
      id: 'compliance_aml_alert',
      personaId: 'compliance',
      title: 'AML Transaction Alert Investigation',
      description: 'Investigating a suspicious transaction pattern flagged by the AML monitoring system with Lisa.',
      initialAiGreeting:
          "Our AML monitoring system flagged a high-priority alert. A corporate account received 15 wire transfers from 8 different countries totaling \$4.2 million within 72 hours. The account holder is a small import-export company with average monthly turnover of \$200,000. We need to investigate immediately.",
      initialOptions: [
        ChatReplyOption(
          text: "That's clearly unusual activity. Have we checked the beneficial ownership structure of the company and the source of funds for these transfers?",
          label: "💡 Recommended",
          translationJa: "明らかに異常な活動ですね。当該企業の実質的支配者の構造と、これらの送金の資金源は確認済みですか？",
          aiReplies: [
            "We've pulled the KYC file. The beneficial owner is a PEP with links to a high-risk jurisdiction. The source of funds documentation is incomplete.",
            "Good question. The beneficial owner information needs updating — the last KYC review was 18 months ago. I'm requesting enhanced due diligence immediately.",
            "I'm running the checks now. Preliminary findings show the company's ownership structure includes a shell company in a jurisdiction with weak AML controls.",
          ],
          nextOptions: [
            ChatReplyOption(
              text: "This looks serious. Should we file a Suspicious Activity Report (SAR) with the financial intelligence unit while we continue investigating?",
              label: "💡 Constructive",
              translationJa: "深刻な状況ですね。調査を続けながら金融情報機関に疑わしい取引の届出（SAR）を提出すべきですか？",
              aiReplies: [
                "Yes, absolutely. Given the red flags — the PEP connection, high-risk jurisdictions, and unusual volume — we have an obligation to file a SAR within 48 hours.",
                "I agree. We should file the SAR immediately and place the account on enhanced monitoring. We may also need to consider restricting the account.",
                "Definitely. I'll prepare the SAR now. We should also consider whether this triggers any sanctions screening obligations given the jurisdictions involved.",
              ],
              nextOptions: [
                ChatReplyOption(
                  text: "Agreed. Please file the SAR, restrict the account, and brief the MLRO. I'll escalate to senior management as required.",
                  label: "💡 Wrap-up",
                  translationJa: "同意します。SARを提出し、口座を制限し、MLROにブリーフィングしてください。必要に応じて上級管理職にエスカレーションします。",
                  aiReplies: [
                    "I'll file the SAR today, place the account on restricted status, and brief the MLRO by end of day. I'll document everything in our case management system.",
                    "On it. I'll also coordinate with our sanctions team to screen all counterparties involved in the wire transfers.",
                    "Will do. I'll prepare a full investigation report with a timeline, red flag analysis, and recommended actions for the compliance committee.",
                  ],
                ),
              ],
            ),
          ],
        ),
        ChatReplyOption(
          text: "The customer has been with us for 5 years. I'm sure it's nothing. Let's just clear the alert and move on.",
          label: "❌ Risky",
          translationJa: "5年間のお客様です。大丈夫でしょう。アラートをクリアして先に進みましょう。",
          aiReplies: [
            "We absolutely cannot dismiss this! Clearing a legitimate AML alert without proper investigation is a serious regulatory violation that could result in massive fines.",
            "Customer tenure is not a reason to ignore red flags. Long-standing customers can be exploited by money launderers. We must investigate thoroughly.",
            "I must strongly object. Ignoring AML alerts is a criminal offense. If this turns out to be money laundering, both the bank and individuals involved face prosecution.",
          ],
          nextOptions: [
            ChatReplyOption(
              text: "I apologize, you're absolutely right. Customer relationship length doesn't override AML obligations. Let's investigate properly.",
              label: "💡 Corrected",
              translationJa: "申し訳ございません、おっしゃる通りです。顧客との取引期間はAML義務に優先しません。適切に調査しましょう。",
              aiReplies: [
                "Thank you for reconsidering. I'll begin the full investigation immediately and keep you informed of our findings.",
                "Appreciated. AML compliance is non-negotiable. I'll start the enhanced due diligence process right away.",
                "Good. Let me proceed with the investigation and prepare the SAR filing as a precautionary measure.",
              ],
            ),
          ],
        ),
      ],
    ),

    RoleplayScenario(
      id: 'compliance_policy_update',
      personaId: 'compliance',
      title: 'Regulatory Policy Update & Training',
      description: 'Implementing new regulatory requirements and staff training programs with Lisa.',
      initialAiGreeting:
          "The financial regulator just published new guidelines on digital asset custody and crypto-related services. Banks offering crypto custody must implement enhanced controls by Q1 next year. Our current policy framework doesn't cover digital assets at all. We need to develop a comprehensive compliance program.",
      initialOptions: [
        ChatReplyOption(
          text: "Understood. Can you outline the key compliance requirements from the new guidelines? Let's start with a gap analysis against our current controls.",
          label: "💡 Recommended",
          translationJa: "了解しました。新ガイドラインの主な遵守要件を概要していただけますか？まず現行の統制とのギャップ分析から始めましょう。",
          aiReplies: [
            "The key requirements are: segregation of customer digital assets, enhanced cybersecurity controls, specialized AML procedures for crypto transactions, and quarterly reporting to the regulator.",
            "Sure. The main areas are: 1) Digital asset custody safeguarding rules, 2) Enhanced KYC for crypto customers, 3) Transaction monitoring for blockchain transfers, and 4) Capital adequacy requirements for crypto exposures.",
            "I've already started the gap analysis. The main gaps are: we lack a digital asset custody policy, our AML system doesn't monitor blockchain transactions, and our staff needs crypto compliance training.",
          ],
          nextOptions: [
            ChatReplyOption(
              text: "Good overview. Let's form a cross-functional project team to address each gap. What's the timeline for implementation?",
              label: "💡 Constructive",
              translationJa: "良い概要ですね。各ギャップに対応するためのクロスファンクショナルプロジェクトチームを結成しましょう。実装のタイムラインはどうですか？",
              aiReplies: [
                "I recommend a 6-month implementation plan: Month 1-2 for policy development, Month 3-4 for system enhancements, and Month 5-6 for testing and staff training.",
                "We have 9 months until the deadline. I'd suggest three phases: policy framework by month 3, technology implementation by month 6, and training and go-live by month 9.",
                "Given the complexity, I'd propose a phased approach with interim milestones. We need IT, legal, risk, and operations involved from day one.",
              ],
              nextOptions: [
                ChatReplyOption(
                  text: "Great plan. Let's present the implementation roadmap to the board next week and secure budget approval.",
                  label: "💡 Wrap-up",
                  translationJa: "素晴らしい計画です。来週取締役会に実装ロードマップを提示し、予算の承認を取りましょう。",
                  aiReplies: [
                    "I'll prepare the board presentation with the roadmap, resource requirements, and budget estimate by Wednesday.",
                    "Sounds good. I'll also include a risk assessment showing the penalties for non-compliance to support the budget request.",
                    "I'll draft the full project plan. Should I also include a recommendation for engaging an external compliance consultant for the specialist areas?",
                  ],
                ),
              ],
            ),
          ],
        ),
        ChatReplyOption(
          text: "Can you just copy another bank's compliance policy and modify it for our use?",
          label: "⚠️ Compliance Trigger",
          translationJa: "他行のコンプライアンスポリシーをコピーして当行向けに修正することはできますか？",
          aiReplies: [
            "That would be a serious compliance failure. Each institution's policy must reflect its unique risk profile, business model, and operational structure.",
            "I can't recommend that. Generic policies don't account for our specific risks and would fail regulatory scrutiny immediately.",
            "Copied policies are a major red flag for regulators. They need to see that our compliance framework is tailored to our actual business activities and risk appetite.",
          ],
          nextOptions: [
            ChatReplyOption(
              text: "Fair point. Let's develop a bespoke policy framework that reflects our specific risk profile and business model.",
              label: "💡 Acknowledge",
              translationJa: "ごもっともです。当行固有のリスクプロファイルとビジネスモデルを反映したオーダーメイドのポリシーフレームワークを策定しましょう。",
              aiReplies: [
                "That's the right approach. I'll start with a thorough risk assessment of our digital asset activities and build the policy from there.",
                "Exactly. While we can reference industry best practices, the policy must be customized. I'll begin drafting our bespoke framework.",
                "Thank you for understanding. I'll develop the policy using a risk-based approach specific to our institution.",
              ],
            ),
          ],
        ),
      ],
    ),

    // ==========================================
    // Yuki (General Customer) Scenarios
    // ==========================================
    RoleplayScenario(
      id: 'customer_account_opening',
      personaId: 'customer',
      title: 'New Account Opening Consultation',
      description: 'Helping a new customer understand account types and guiding them through the account opening process.',
      initialAiGreeting:
          "Hello! I'd like to open a bank account, but I'm not sure which type would be best for me. I have about \$15,000 in savings and I receive my salary via direct deposit. I also want to start saving for retirement. Can you help me understand my options?",
      initialOptions: [
        ChatReplyOption(
          text: "Of course! Based on your needs, I'd recommend opening both a checking account for daily transactions and a high-yield savings account. Would you also be interested in learning about our retirement savings plans?",
          label: "💡 Recommended",
          translationJa: "もちろんです！ご要望に基づき、日常取引用の当座預金口座と高利回り普通預金口座の両方を開設されることをお勧めします。退職貯蓄プランについてもお知りになりたいですか？",
          aiReplies: [
            "Yes, I'd love to hear about the retirement options! I'm 32 years old and want to start early. What's the difference between a 401(k) and an IRA?",
            "A high-yield savings account sounds great! What's the current interest rate, and are there any minimum balance requirements? And yes, I'm interested in retirement planning.",
            "Both accounts sound useful. Can I set up automatic transfers from my checking to savings? And I'd definitely like to learn about retirement options.",
          ],
          nextOptions: [
            ChatReplyOption(
              text: "Great questions! Our high-yield savings offers 4.5% APY with no minimum balance. For retirement, an IRA is a great starting point since you can contribute up to \$6,500 annually with tax advantages.",
              label: "💡 Informative",
              translationJa: "素晴らしいご質問です！当行の高利回り普通預金は最低残高なしで年利4.5%です。退職後については、年間最大6,500ドルを税優遇で拠出できるIRAが良い出発点です。",
              aiReplies: [
                "4.5% sounds wonderful! And I think an IRA makes sense for me. Can I open both the savings account and the IRA today?",
                "That's a much better rate than my current bank. What documents do I need to bring to open these accounts?",
                "Thank you for explaining so clearly! Let me start with the checking and savings accounts first, and I'll come back to discuss the IRA in detail.",
              ],
              nextOptions: [
                ChatReplyOption(
                  text: "Absolutely! You'll need a government-issued photo ID and proof of address. We can complete the application right now. It takes about 15 minutes.",
                  label: "💡 Wrap-up",
                  translationJa: "もちろんです！政府発行の写真付き身分証明書と住所証明が必要です。今すぐ申請手続きを行えます。約15分で完了します。",
                  aiReplies: [
                    "I have my passport and a utility bill with me. Let's get started! Thank you for making this so easy to understand.",
                    "Perfect, I brought my driver's license and a bank statement. Let's open the accounts today!",
                    "Great! I'm ready to proceed. One last question — is there an app I can use to manage my accounts on my phone?",
                  ],
                ),
              ],
            ),
          ],
        ),
        ChatReplyOption(
          text: "You should invest all \$15,000 in our highest-risk investment product for maximum returns.",
          label: "❌ Risky",
          translationJa: "最大のリターンのために15,000ドル全額を最もリスクの高い投資商品に投資すべきです。",
          aiReplies: [
            "That sounds very risky! I'm not comfortable putting all my savings into a high-risk product. Don't I need some money accessible for emergencies?",
            "I'm not sure about that. I've heard you should always keep an emergency fund. Are you sure investing everything is the right advice?",
            "That makes me uncomfortable. I just want to save safely and plan for retirement. I don't want to gamble with all my money.",
          ],
          nextOptions: [
            ChatReplyOption(
              text: "I apologize, that was poor advice. You're right — it's important to maintain an emergency fund of 3-6 months of expenses before investing. Let me suggest a more balanced approach.",
              label: "💡 Corrected",
              translationJa: "申し訳ございません、適切でないアドバイスでした。おっしゃる通り、投資の前に3〜6ヶ月分の緊急資金を確保することが重要です。よりバランスの取れたアプローチをご提案させてください。",
              aiReplies: [
                "Thank you for correcting that. Yes, I'd like a safer approach. Maybe keep some in savings and invest a smaller portion?",
                "I appreciate your honesty. A balanced approach sounds much better. Can you walk me through the options?",
                "That makes more sense. I'd like to keep at least \$10,000 accessible and maybe invest the rest more conservatively.",
              ],
              nextOptions: [
                ChatReplyOption(
                  text: "That's a wise plan. Let's keep \$10,000 in a high-yield savings account and explore conservative investment options for the remaining \$5,000.",
                  label: "💡 Wrap-up",
                  translationJa: "賢明な計画です。10,000ドルを高利回り普通預金に、残りの5,000ドルは保守的な投資オプションを検討しましょう。",
                  aiReplies: [
                    "That sounds perfect! I feel much more comfortable with that approach. When can we get started?",
                    "I like that balance. Thank you for taking the time to understand my needs properly.",
                    "Great plan! I appreciate you helping me think this through carefully rather than rushing into something risky.",
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    RoleplayScenario(
      id: 'customer_mortgage_consultation',
      personaId: 'customer',
      title: 'Mortgage Consultation',
      description: 'Consulting with a customer who wants to apply for a home mortgage loan.',
      initialAiGreeting:
          "Hi there! My spouse and I are looking to buy our first home. We found a house listed at \$450,000 and we've saved \$90,000 for the down payment. Our combined annual income is \$120,000. Can you help us understand if we qualify for a mortgage and what our options are?",
      initialOptions: [
        ChatReplyOption(
          text: "Congratulations on finding a home! With \$90,000 down on a \$450,000 home, that's a 20% down payment, which is excellent — it means you'll avoid private mortgage insurance. Let me walk you through the loan options.",
          label: "💡 Recommended",
          translationJa: "お家が見つかったとのこと、おめでとうございます！45万ドルの住宅に対して9万ドルの頭金は20%にあたり、非常に良いです。住宅ローン保険が不要になります。融資オプションをご説明しますね。",
          aiReplies: [
            "Oh, we didn't know about private mortgage insurance! That's great to hear. What's the difference between a fixed-rate and an adjustable-rate mortgage?",
            "That's a relief about the insurance! We want the most predictable monthly payment possible. What would our monthly payment look like?",
            "Thank you! We've been saving for years. What interest rates are available right now, and how long is the approval process?",
          ],
          nextOptions: [
            ChatReplyOption(
              text: "Great question! A 30-year fixed rate gives you predictable payments at 6.5% APR. Your estimated monthly payment would be about \$2,275 including taxes and insurance. An ARM starts lower at 5.5% but adjusts after 5 years.",
              label: "💡 Informative",
              translationJa: "良い質問です！30年固定金利は6.5%で安定した月々の返済額になります。税金と保険込みで月々約2,275ドルです。ARMは5.5%で開始しますが5年後に変動します。",
              aiReplies: [
                "\$2,275 per month fits our budget. We'd prefer the fixed rate for stability. What documents do we need to apply?",
                "The fixed rate sounds safer for us since it's our first home. How long does the mortgage approval process typically take?",
                "We like the predictability of fixed rate. Is there a pre-approval process we can start while we finalize the home purchase?",
              ],
              nextOptions: [
                ChatReplyOption(
                  text: "I'd recommend starting with a pre-approval. You'll need recent pay stubs, tax returns for 2 years, bank statements, and photo ID. Pre-approval typically takes 2-3 business days.",
                  label: "💡 Wrap-up",
                  translationJa: "事前審査から始めることをお勧めします。直近の給与明細、過去2年分の確定申告書、銀行取引明細書、写真付き身分証明書が必要です。事前審査は通常2〜3営業日で完了します。",
                  aiReplies: [
                    "We can gather all those documents this week! Thank you so much for explaining everything so clearly. We're excited to get started!",
                    "That sounds manageable. We'll bring everything in this Saturday. Thank you for making this less intimidating!",
                    "Wonderful! We feel much more confident now. Let's schedule an appointment for the pre-approval application.",
                  ],
                ),
              ],
            ),
          ],
        ),
        ChatReplyOption(
          text: "Your income is too low to buy a \$450,000 home. You should look for something cheaper.",
          label: "⚠️ Customer Trigger",
          translationJa: "45万ドルの家を購入するには収入が不十分です。もっと安い物件を探すべきです。",
          aiReplies: [
            "Oh... that's disappointing. But are you sure? We've calculated that we can afford the monthly payments. Could you at least run the numbers for us?",
            "That's discouraging to hear. We've been planning this for years. Is there really no way to make this work with our income and down payment?",
            "I'm surprised you say that without even looking at our finances in detail. Our debt-to-income ratio should be within limits.",
          ],
          nextOptions: [
            ChatReplyOption(
              text: "I apologize for the hasty assessment. Let me actually calculate your debt-to-income ratio properly. With \$120,000 income and 20% down payment, you may very well qualify. Let me run the numbers.",
              label: "💡 Corrected",
              translationJa: "性急な判断で申し訳ございません。実際に返済比率を正しく計算させてください。年収12万ドルと20%の頭金であれば十分に審査通過の可能性があります。数字を確認しましょう。",
              aiReplies: [
                "Thank you for taking another look. We've done our homework and we're confident we can manage the payments.",
                "We appreciate you reconsidering. Please do run the numbers — we want to make an informed decision based on facts.",
                "I'm glad you're willing to check properly. We have no other debts, which should help our case.",
              ],
              nextOptions: [
                ChatReplyOption(
                  text: "You're right, and I'm sorry for the initial response. With no other debts and 20% down, your debt-to-income ratio is about 23%, which is well within our 36% limit. You should qualify comfortably.",
                  label: "💡 Wrap-up",
                  translationJa: "おっしゃる通りで、最初のお答えを申し訳なく思います。他の借入がなく頭金20%の場合、返済比率は約23%で、当行の上限36%を十分に下回っています。問題なく審査に通る見込みです。",
                  aiReplies: [
                    "That's wonderful news! We're so relieved. When can we start the application process?",
                    "Thank you! We knew we'd done the math correctly. Let's move forward with the pre-approval right away.",
                    "We're thrilled to hear that. Thank you for running the actual numbers. Let's get started!",
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ];
}
